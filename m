From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 5/5] ISDN-Gigaset: Enclose two expressions for the
 sizeof operator by parentheses
Date: Mon, 26 Sep 2016 09:23:23 -0700
Message-ID: <1474907003.2238.13.camel@perches.com>
References: <566ABCD9.1060404@users.sourceforge.net>
         <6d4bbb77-914f-19b8-a1a9-2731d1158612@users.sourceforge.net>
         <e97b38b6-8c02-6733-8b57-9786bfb911a6@users.sourceforge.net>
         <063D6719AE5E284EB5DD2968C1650D6DB0109E63@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
        Julia Lawall <julia.lawall@lip6.fr>
To: David Laight <David.Laight@ACULAB.COM>,
        'SF Markus Elfring' <elfring@users.sourceforge.net>,
        "gigaset307x-common@lists.sourceforge.net"
        <gigaset307x-common@lists.sourceforge.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Karsten Keil <isdn@linux-pingi.de>,
        Paul Bolle <pebolle@tiscali.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB0109E63@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-09-26 at 16:00 +0000, David Laight wrote:
> From: SF Markus Elfring Sent: 26 September 2016 16:45
> > The script "checkpatch.pl" can point information out like the following.
> > WARNING: sizeof … should be sizeof(…)
> []
> > diff --git a/drivers/isdn/gigaset/common.c b/drivers/isdn/gigaset/common.c
[]
> > @@ -53,7 +53,7 @@ void gigaset_dbg_buffer(enum debuglevel level, const unsigned char *msg,
> >  {
> >  	unsigned char outbuf[80];
> >  	unsigned char c;
> > -	size_t space = sizeof outbuf - 1;
> > +	size_t space = sizeof(outbuf - 1);

> wrong ...
> think that is 7 instead of 79.


Well, it's sizeof(pointer) so either 4 or 8, but still,
what Markus proposes here is _wrong_.

Markus, do you know the script probably has a lower
style conversion defect introduction rate than you do
when doing these mechanical things.

Please use it to verify what you are doing before
submitting more defective patches.

Excuses and apologies aren't good enough at this point.
