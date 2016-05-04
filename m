From: Lars Ellenberg <lars.ellenberg-63ez5xqkn6DQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next v2] block/drbd: use
 nla_put_u64_64bit()
Date: Wed, 4 May 2016 14:52:53 +0200
Message-ID: <20160504125253.GP16459@soda.linbit>
References: <57286F49.8050107@6wind.com>
	<1462268358-19044-1-git-send-email-nicolas.dichtel@6wind.com>
	<20160503100644.GE16459@soda.linbit>
	<20160503.120556.1317913903199470646.davem@davemloft.net>
	<20160504090529.GJ16459@soda.linbit> <5729EFBC.7040002@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, drbd-dev-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	philipp.reisner-63ez5xqkn6DQT0dZR+AlfA@public.gmane.org
To: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Return-path: <drbd-dev-bounces-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <5729EFBC.7040002-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <http://lists.linbit.com/mailman/options/drbd-dev>,
	<mailto:drbd-dev-request-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linbit.com/pipermail/drbd-dev>
List-Post: <mailto:drbd-dev-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org>
List-Help: <mailto:drbd-dev-request-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org?subject=help>
List-Subscribe: <http://lists.linbit.com/mailman/listinfo/drbd-dev>,
	<mailto:drbd-dev-request-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org?subject=subscribe>
Sender: drbd-dev-bounces-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org
Errors-To: drbd-dev-bounces-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, May 04, 2016 at 02:49:00PM +0200, Nicolas Dichtel wrote:
> Le 04/05/2016 11:05, Lars Ellenberg a =E9crit :
> [snip]
> > We don't have an "alignment problem" there, btw.
> > Last time I checked, we did work fine without this alignment magic,
> > we already take care of that, yes, even on affected architectures.
> The code adds several consecutive u64 attributes. The nl attribute header=
 is 4
> bytes, thus the full attribute length is 12 bytes. If the first u64 is al=
igned
> on 8 (nla_data()), the next one is not aligned on 8: it starts 12 bytes (=
8 (u64)
> + 4 (nl attr hdr)) after the previous u64.

Yes.  Which in our case is not a problem.
But I don't object to the padding per se,
if that is how things "should be".

I try to understand why you so much object to using 0 as pad.

    Lars
