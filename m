From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH 5/5] ISDN-Gigaset: Enclose two expressions for the sizeof
 operator by parentheses
Date: Tue, 27 Sep 2016 10:25:36 +0300
Message-ID: <20160927072536.GV13620@mwanda>
References: <566ABCD9.1060404@users.sourceforge.net>
 <6d4bbb77-914f-19b8-a1a9-2731d1158612@users.sourceforge.net>
 <e97b38b6-8c02-6733-8b57-9786bfb911a6@users.sourceforge.net>
 <248e685c-4875-7acc-afaf-8b2ce00bb5f5@cogentembedded.com>
 <20160927070837.GS13620@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: SF Markus Elfring <elfring@users.sourceforge.net>,
        gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
        Karsten Keil <isdn@linux-pingi.de>,
        Paul Bolle <pebolle@tiscali.nl>,
        LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160927070837.GS13620@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 27, 2016 at 10:08:37AM +0300, Dan Carpenter wrote:
> On Mon, Sep 26, 2016 at 08:38:14PM +0300, Sergei Shtylyov wrote:
> > >@@ -53,7 +53,7 @@ void gigaset_dbg_buffer(enum debuglevel level, const unsigned char *msg,
> > > {
> > > 	unsigned char outbuf[80];
> > > 	unsigned char c;
> > >-	size_t space = sizeof outbuf - 1;
> > >+	size_t space = sizeof(outbuf - 1);
> > 
> >    What?! Does that compile?
> > 
> > [...]
> 
> It prints a Smatch warning.  Smatch ignores these if they happen inside
> a macro where you pass a pointer and it takes the sizeof() the argument.

Reading that again, I realize it's not clear.  Smatch ignores these any
time they happen in a macro whether they're valid or not.  (Many times
they are valid).

regards,
dan carpenter

