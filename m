From: Edward Cree via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: [PATCH v3 net-next 00/12] bpf: rewrite value
	tracking in verifier
Date: Fri, 7 Jul 2017 13:50:41 +0100
Message-ID: <cf2cba1a-78d4-e893-1126-95c3c6a3d94f@solarflare.com>
References: <adc11342-737f-4e06-bce3-f0a92b5594a5@solarflare.com>
	<5953B436.6030506@iogearbox.net>
	<788035e1-1974-b48e-3008-d294194a8b05@solarflare.com>
	<595413AA.40502@iogearbox.net>
	<20170628213701.32krfuipzngsmt4k@ast-mbp>
	<91267d15-652a-16d9-4ee9-42958bd842aa@solarflare.com>
	<ff1ef3ef-71ef-4c23-ede4-b8caeac561ee@fb.com>
	<5fa61129-fa82-1607-3363-dfad86aecf1e@solarflare.com>
	<595C1685.4060209@iogearbox.net>
	<54b95191-697d-6b15-ec39-438c85e08adc@solarflare.com>
	<595F50F3.2030008@iogearbox.net>
Reply-To: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>, Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>,
	Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <595F50F3.2030008-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
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

On 07/07/17 10:14, Daniel Borkmann wrote:
> But this means the bpf_lxc_* cases increase quite significantly,
> arguably one of them is pretty close already, but the other one not
> so much, meaning while 142k would shoot over the 128k target quite a
> bit, the 95k is quite close to the point that it wouldn't take much,
> say, few different optimizations from compiler, to hit the limit as
> well eventually, something like 156k for the time being would seem a
> more adequate raise perhaps that needs to be evaluated carefully
> given the situation.
Note that the numbers in my table are the _sum_ of all the progs in the
 object file, not the #insns for a single program.  (Hence the awk
 invocation in my pipeline.)  For instance in bpf_lxc_opt_-DUNKNOWN.o
 on net-next there were (iirc) a couple of 30k progs and then some
 smaller ones, not a single 93k prog.

-Ed
