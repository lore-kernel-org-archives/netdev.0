From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v7 0/2] bpf: add bpf_probe_write_user helper &
 example
Date: Mon, 25 Jul 2016 18:08:05 -0700 (PDT)
Message-ID: <20160725.180805.1078640844978833041.davem@davemloft.net>
References: <20160725125426.GA15045@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	alexei.starovoitov@gmail.com, daniel@iogearbox.net
To: sargun@sargun.me
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160725125426.GA15045@ircssh.c.rugged-nimbus-611.internal>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sargun Dhillon <sargun@sargun.me>
Date: Mon, 25 Jul 2016 05:54:29 -0700

> This patch series contains two patches that add support for a probe_write
> helper to BPF programs. This allows them to manipulate user memory during
> the course of tracing. The second patch in the series has an example that
> uses it, in one the intended ways to divert execution.
> 
> Thanks to Alexei Starovoitov, and Daniel Borkmann for being patient, review, and 
> helping me get familiar with the code base. I've made changes based on their 
> recommendations.
> 
> This helper should be considered for experimental usage and debugging, so we
> print a warning to dmesg when it is along with the command and pid when someone
> tries to install a proglet that uses it. A follow-up patchset will contain a
> mechanism to verify the safety of the probe beyond what was done by hand.

Series applied, thanks.
