From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Subject: Re: 2.6.27-rc8-git7: Reported regressions from 2.6.26
Date: Sun, 05 Oct 2008 19:49:31 +0800
Message-ID: <E1KmS79-0003mo-5j@gondolin.me.apana.org.au>
References: <200810051302.20896.rjw@sisk.pl>
Cc: johnpol-9fLWQ3dKdXwox3rIn2DAYQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	protasnb-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
To: rjw-KKrjLPT3xs0@public.gmane.org (Rafael J. Wysocki)
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200810051302.20896.rjw-KKrjLPT3xs0@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org> wrote:
>> > Bug-Entry   : http://bugzilla.kernel.org/show_bug.cgi?id=11308
>> > Subject             : tbench regression on each kernel release from 2.6.22 -&gt; 2.6.28
>> > Submitter   : Christoph Lameter <cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
>> > Date                : 2008-08-11 18:36 (55 days old)
>> > References  : http://marc.info/?l=linux-kernel&m=121847986119495&w=4
>> >               http://marc.info/?l=linux-kernel&m=122125737421332&w=4
>> 
>> Just for the reference, this one regresses from the 2.6.23.
> 
> Still, tbench results from 2.6.26 are better than from 2.6.27-rc.
> That's why it's still on the list, but if you think that's not relevant, please
> let me know and I'll drop it.

Note that 2.6.27 beats 2.6.26 by 30% with bulk traffic over
loopback as opposed to the small packets sent by tbench where
I saw a 5% drop in performance on my machine.

So I'm not sure whether this should really be classified as
a regression if we limit ourselves to the changes between 26
and 27.

The changes prior to 26 seem to be more significant.

Chyeers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
