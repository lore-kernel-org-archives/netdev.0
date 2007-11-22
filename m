From: "Dave Young" <hidave.darkstar@gmail.com>
Subject: Re: [PATCH RFC] [1/9] Core module symbol namespaces code and intro.
Date: Thu, 22 Nov 2007 16:41:43 +0800
Message-ID: <a8e1da0711220041v3d3c27d2pf7f326185666420d@mail.gmail.com>
References: <20071122343.446909000@suse.de>
	 <200711221456.22297.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Andi Kleen" <ak@suse.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, sam@ravnborg.org
To: "Rusty Russell" <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.237]:50238 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750971AbXKVIlo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Nov 2007 03:41:44 -0500
Received: by wx-out-0506.google.com with SMTP id h31so1146074wxd
        for <netdev@vger.kernel.org>; Thu, 22 Nov 2007 00:41:44 -0800 (PST)
In-Reply-To: <200711221456.22297.rusty@rustcorp.com.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Nov 22, 2007 11:56 AM, Rusty Russell <rusty@rustcorp.com.au> wrote:
> On Thursday 22 November 2007 13:43:06 Andi Kleen wrote:
> > There seems to be rough consensus that the kernel currently has too many
> > exported symbols. A lot of these exports are generally usable utility
> > functions or important driver interfaces; but another large part are
> > functions intended by only one or two very specific modules for a very
> > specific purpose.
>
> Hi Andi,
>
>     This is an interesting idea, thanks for the code!  My only question is
> whether we can get most of this benefit by dropping the indirection of
> namespaces and have something like "EXPORT_SYMBOL_TO(sym, modname)"?

Andy, I like your idea.  IMHO, as Rusty said a simple EXPORT_SYMBOL_TO
is better.

And I wonder if it is possible to export to something like  the struct
device_driver? If it's possible then it will not limited to modules.

> doesn't work so well for exporting to a group of modules, but that seems
> a reasonable line to draw anyway.
>
> Cheers,
> Rusty.
> PS.  Probably better to use the standard warnx and errx in modpost, too.
>
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>
