From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: WARNING: at net/ipv4/tcp_input.c:2054 tcp_mark_head_lost()
Date: Wed, 27 Feb 2008 21:29:08 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0802272120430.1741@kivilampi-30.cs.helsinki.fi>
References: <858077.97160.qm@web39709.mail.mud.yahoo.com>
 <20080223000310.4630daa8.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0802271108290.13029@kivilampi-30.cs.helsinki.fi>
 <3d8471ca0802271056l320a7ee2m5227e114a968d483@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/Mixed; boundary="=_courier-8386-1204138613-0001-2"
Cc: Giangiacomo Mariotti <giangiacomo_mariotti@yahoo.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Guillaume Chazarain <guichaz@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758242AbYB0T3W@vger.kernel.org>
In-Reply-To: <3d8471ca0802271056l320a7ee2m5227e114a968d483@mail.gmail.com>
Content-ID: <Pine.LNX.4.64.0802272120431.1741@kivilampi-30.cs.helsinki.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--=_courier-8386-1204138613-0001-2
Content-Type: TEXT/PLAIN; charset=utf-8
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0802272120432.1741@kivilampi-30.cs.helsinki.fi>
Content-Disposition: inline

On Wed, 27 Feb 2008, Guillaume Chazarain wrote:

> On Wed, Feb 27, 2008 at 10:29 AM, Ilpo Järvinen 
> <ilpo.jarvinen@helsinki.fi> wrote:
> > I did in the past a debug patch
> >  that verifies TCP's write queue state by the hard way, ie., by 
> >  bruteforce
> >  walking often enough to catch inconsistencies early enough to find 
> >  out
> >  the root cause.
> 
> Are you talking about this one:
> http://marc.info/?l=linux-netdev&m=119482084511178 ?
> I attached a forward port to current git.

No, I'd much more complete set of tests than in that one.

> I am using this patch, and caught this maybe related error while 
> Bittorrenting:
>
> KERNEL: assertion (packets <= tp->packets_out) failed at
> /home/g/linux-2.6/net/ipv4/tcp_input.c (2145)
> KERNEL: assertion (packets <= tp->packets_out) failed at
> /home/g/linux-2.6/net/ipv4/tcp_input.c (2145)
> ------------[ cut here ]------------
> WARNING: at /home/g/linux-2.6/net/ipv4/tcp_input.c:2515
> tcp_fastretrans_alert+0xa5/0xa4f()

You seem to be good in catching these... :-)


-- 
 i.
--=_courier-8386-1204138613-0001-2--
