From: Dmitriy Pichugin <smokeman85@gmail.com>
Subject: Re: [PATCH] cfg80211 debugfs: Cleanup some checkpatch issues
Date: Sat, 28 Jan 2017 14:49:00 +0300
Message-ID: <20170128114859.GA2482@gmail.com>
References: <20170127192603.GA13522@gmail.com>
 <1485546515.12563.138.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johannes@sipsolutions.net, davem@davemloft.net,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:32878 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750837AbdA1LwG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Jan 2017 06:52:06 -0500
Content-Disposition: inline
In-Reply-To: <1485546515.12563.138.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 27, 2017 at 11:48:35AM -0800, Joe Perches wrote:
> On Fri, 2017-01-27 at 22:26 +0300, Pichugin Dmitry wrote:
> > This fixes the checkpatch.pl warnings:
> > * Macros should not use a trailing semicolon.
> > * Spaces required around that '='.
> > * Symbolic permissions 'S_IRUGO' are not preferred.
> 
> OK
> 
> > * Macro argument reuse 'buflen' - possible side-effects
> 
> Not all checkpatch messages need fixing.
> This is one of them.
> 
> > diff --git a/net/wireless/debugfs.c b/net/wireless/debugfs.c
> []
> > @@ -17,11 +17,12 @@
> >  static ssize_t name## _read(struct file *file, char __user *userbuf,	\
> >  			    size_t count, loff_t *ppos)			\
> >  {									\
> > -	struct wiphy *wiphy= file->private_data;		\
> > -	char buf[buflen];						\
> > +	struct wiphy *wiphy = file->private_data;			\
> > +	int __buflen = __builtin_constant_p(buflen) ? buflen : -1;	\
> > +	char buf[__buflen];						\
> 
> That's rather an odd change too
> 
OK. I will update the patch.

Best Regards,
Dmitriy.
