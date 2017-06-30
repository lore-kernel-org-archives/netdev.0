From: Alexei Starovoitov via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: [PATCH v3 net-next 00/12] bpf: rewrite value
	tracking in verifier
Date: Fri, 30 Jun 2017 11:15:39 -0700
Message-ID: <ff1ef3ef-71ef-4c23-ede4-b8caeac561ee@fb.com>
References: <adc11342-737f-4e06-bce3-f0a92b5594a5@solarflare.com>
	<5953B436.6030506@iogearbox.net>
	<788035e1-1974-b48e-3008-d294194a8b05@solarflare.com>
	<595413AA.40502@iogearbox.net>
	<20170628213701.32krfuipzngsmt4k@ast-mbp>
	<91267d15-652a-16d9-4ee9-42958bd842aa@solarflare.com>
Reply-To: Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>, Alexei Starovoitov
	<alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <91267d15-652a-16d9-4ee9-42958bd842aa-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
List-Unsubscribe: <https://lists.iovisor.org/mailman/options/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.iovisor.org/pipermail/iovisor-dev/>
List-Post: <mailto:iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
List-Help: <mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=help>
List-Subscribe: <https://lists.iovisor.org/mailman/listinfo/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=subscribe>
Sender: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
Errors-To: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
List-Id: netdev.vger.kernel.org

On 6/30/17 9:44 AM, Edward Cree wrote:
> I haven't measured the test_progs ones, because I *still* haven't gotten
>  around to actually setting up a BPF toolchain (it doesn't help that I'm
>  building everything on a test server that gets reimaged every night to
>  run our nightly tests...).

then you're missing a lot of tests then...
installing llvm is trivial. On x86 there are plenty of pre-built
packages that you can apt-get or yum.
Dave had to compile llvm and gcc from source on sparc, so volatile test
server isn't really an excuse to miss all these tests ;)
especially for such large verifier change.
