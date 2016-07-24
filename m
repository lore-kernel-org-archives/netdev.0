From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next v6 0/2] bpf: add bpf_probe_write_user helper &
 example
Date: Sat, 23 Jul 2016 20:50:00 -0700
Message-ID: <20160724034958.GA35383@ast-mbp.thefacebook.com>
References: <20160724032201.GA1631@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	daniel@iogearbox.net
To: Sargun Dhillon <sargun@sargun.me>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160724032201.GA1631@ircssh.c.rugged-nimbus-611.internal>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 23, 2016 at 08:22:04PM -0700, Sargun Dhillon wrote:
> This patch series contains two patches that add support for a probe_write
> helper to BPF programs. This allows them to manipulate user memory during
> the course of tracing. The second patch in the series has an example that
> uses it, in one the intended ways to divert execution.
> 
> Thanks to Alexei Starovoitov, and Daniel Borkmann for review, I've made
> changes based on their recommendations. 
> 
> This helper should be considered experimental, so we print a warning
> to dmesg when it is along with the command and pid. A follow-up patchset
> will contain a mechanism to verify the safety of the probe beyond what
> was done by hand.

I'd like to clarify above 'helper is experimental' meaning that
it should only be used for experiments and not production.
That's what the warning is for.
If Dave applies it, it will be permanent abi and cannot be removed.
In other words it's for debugging user apps and trying out crazy ideas.
Like we will use to experiment with different approaches around
restartable sequences and tracing.
