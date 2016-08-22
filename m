From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] checkpatch: See if modified files are marked obsolete
 in MAINTAINERS
Date: Mon, 22 Aug 2016 13:56:07 -0700
Message-ID: <1471899367.3746.78.camel@perches.com>
References: <87shtwvm63.fsf@kamboji.qca.qualcomm.com>
         <7ceaa510dc9d2df05ec4b456baed7bb1415550b3.1471889575.git.joe@perches.com>
         <30522d64-8303-cf13-d967-a5759aeb2278@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Kalle Valo <kvalo@codeaurora.org>,
        Arend van Spriel <arend.vanspriel@broadcom.com>,
        Andy Whitcroft <apw@canonical.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        Jouni Malinen <j@w1.fi>, kernel-janitors@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>,
        linux-kernel@vger.kernel.org
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <30522d64-8303-cf13-d967-a5759aeb2278@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-08-22 at 22:50 +0200, SF Markus Elfring wrote:
> > @@ -2289,6 +2299,10 @@ sub process {
> >  		}
> >  
> >  		if ($found_file) {
> > +			if (is_maintained_obsolete($realfile)) {
> > +				WARN("OBSOLETE",
> > +				     "$realfile is marked as 'obsolete' in the MAINTAINERS hierarchy.  No unnecessary modifications please.\n");
> > +			}
> How do you think about to avoid a double negation in such a warning message?
> 
> Would a wording like "… Only really necessary modifications please.\n"
> be more useful here?

No, probably not.
