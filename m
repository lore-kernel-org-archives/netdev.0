From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: Adding an IW_QUAL_ALL_UPDATED macro
Date: Fri, 28 Jan 2005 08:36:15 -0800
Message-ID: <20050128163615.GA14063@bougret.hpl.hp.com>
References: <Pine.LNX.4.58.0501272121120.2149@devserv.devel.redhat.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Dan Williams <dcbw@redhat.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0501272121120.2149@devserv.devel.redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jan 27, 2005 at 09:27:55PM -0500, Dan Williams wrote:
> Jean,
> 
> Can we add something like:
> 
> #define IW_QUAL_ALL_UPDATED (IW_QUAL_QUAL_UPDATED
>                              | IW_QUAL_LEVEL_UPDATED
>                              | IW_QUAL_NOISE_UPDATED)
> 
> #define IW_QUAL_ALL_INVALID (IW_QUAL_QUAL_INVALID
>                              | IW_QUAL_LEVEL_INVALID
>                              | IW_QUAL_NOISE_INVALID)
> 
> these macros to wireless.h?  This would be helpful for drivers, many 
> of which seem to have "qual.updated = 7; /* all updated */" type 
> statements in them.

	Ok, I'll push that in WE-18. Meanwhile, you can have local
defs protected by #ifdef.

> I'm also attempting to normalize some of the quality values in the 
> drivers, and to develop an understanding of the spreads of the quality 
> values in all of them.  I hope to post the data from this evaluation at 
> some point.  I'm fixing up the in-kernel drivers (and ipw2200 driver) to 
> correctly set the "qual.updated" field since most of them don't.

	Be aware that those defines, IW_QUAL_XXX, were only introduced
in WE-17, which means 2.6.10 and later. For driver outside the kernel,
you need to have local definition is WIRELESS_EXT < 17.

> Dan

	Thanks,

	Jean
