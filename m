From: Thomas Monjalon via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: XDP seeking input from NIC hardware vendors
Date: Tue, 26 Jul 2016 15:31:44 +0200
Message-ID: <1619174.FzfZHYFiS5@xps13>
References: <20160707124245.6d95635a@redhat.com> <5785413D.4050901@gmail.com>
	<20160712223231.202cd122@redhat.com>
Reply-To: Thomas Monjalon <thomas.monjalon-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jakub Kicinski <jakub.kicinski-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>, adrien.mazarguil-pdR9zngts4EAvxtiuMwx3w@public.gmane.org,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org, "Fastabend,
	John R" <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Rana Shahout <ranas-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Simon Horman <simon.horman-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>,
	Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, Ari Saha <as754m-60p5jsuXm+c@public.gmane.org>
To: Jesper Dangaard Brouer <brouer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	John Fastabend <john.fastabend-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <20160712223231.202cd122-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

Hi,

About RX filtering, there is an ongoing effort in DPDK to write an API
which could leverage most of the hardware capabilities of any NICs:
	https://rawgit.com/6WIND/rte_flow/master/rte_flow.html
	http://thread.gmane.org/gmane.comp.networking.dpdk.devel/43352
I understand that XDP does not target to support every hardware features,
though it may be an interesting approach to check.

2016-07-12 22:32, Jesper Dangaard Brouer via iovisor-dev:
> On Tue, 12 Jul 2016 12:13:01 -0700
> John Fastabend <john.fastabend-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> > 
> > Another use case I have is to make a really high performance AF_PACKET
> > interface. So if there was a way to say bind a queue to an AF_PACKET
> > ring and run a policy XDP program before hitting the AF_PACKET
> > descriptor bit that would be really interesting because it would solve
> > some of my need for poll mode drivers in userspace.

Have you started this work?
Do you have an idea of how RX would perform through XDP + AF_PACKET + DPDK?

> +1 yes, a super fast AF_PACKET is also on my wish/todo list for XDP.
> It would basically allow for implementing DPDK or netmap on top of XDP
> (as least the RX side) without needing to run a NIC driver in userspace.

Why TX would not be possible through AF_PACKET?
