From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH 5/5] ISDN-Gigaset: Enclose two expressions for the sizeof
 operator by parentheses
Date: Mon, 26 Sep 2016 18:50:38 +0200 (CEST)
Message-ID: <alpine.DEB.2.10.1609261849580.3199@hadrien>
References: <566ABCD9.1060404@users.sourceforge.net> <6d4bbb77-914f-19b8-a1a9-2731d1158612@users.sourceforge.net> <e97b38b6-8c02-6733-8b57-9786bfb911a6@users.sourceforge.net> <063D6719AE5E284EB5DD2968C1650D6DB0109E63@AcuExch.aculab.com> <1474907003.2238.13.camel@perches.com>
 <d325c0ab-9f1b-e00d-6b4c-30f39d939ab4@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Joe Perches <joe@perches.com>,
        David Laight <David.Laight@ACULAB.COM>,
        "gigaset307x-common@lists.sourceforge.net"
        <gigaset307x-common@lists.sourceforge.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Karsten Keil <isdn@linux-pingi.de>,
        Paul Bolle <pebolle@tiscali.nl>,
        LKML <linux-kernel@vger.kernel.org>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
        Julia Lawall <julia.lawall@lip6.fr>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <d325c0ab-9f1b-e00d-6b4c-30f39d939ab4@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Mon, 26 Sep 2016, SF Markus Elfring wrote:

> >>> @@ -53,7 +53,7 @@ void gigaset_dbg_buffer(enum debuglevel level, const unsigned char *msg,
> >>>  {
> >>>  	unsigned char outbuf[80];
> >>>  	unsigned char c;
> >>> -	size_t space = sizeof outbuf - 1;
> >>> +	size_t space = sizeof(outbuf - 1);
> >
> >> wrong ...
> >> think that is 7 instead of 79.
> >
> >
> > Well, it's sizeof(pointer) so either 4 or 8, but still,
> > what Markus proposes here is _wrong_.
>
> You are right at this place.
>
>
> > Markus, do you know the script probably has a lower
> > style conversion defect introduction rate than you do
> > when doing these mechanical things.
>
> Would it be nice if the script "checkpatch.pl" could avoid to point
> such a false positive out anyhow?

checkpatch reports:

WARNING: sizeof outbuf should be sizeof(outbuf)
#56: FILE: drivers/isdn/gigaset/common.c:56:
+	size_t space = sizeof outbuf - 1;

There is nothing wrong with the report,

julia

>
>
> > Please use it to verify what you are doing before
> > submitting more defective patches.
>
> Do you expect a resend for this update step so that an other statement
> in the function "gigaset_initdriver" would eventually be adjusted?
>
> Regards,
> Markus
> --
> To unsubscribe from this list: send the line "unsubscribe kernel-janitors" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
