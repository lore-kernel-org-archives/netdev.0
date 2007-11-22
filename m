From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH RFC] [1/9] Core module symbol namespaces code and intro.
Date: Thu, 22 Nov 2007 14:56:22 +1100
Message-ID: <200711221456.22297.rusty@rustcorp.com.au>
References: <20071122343.446909000@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sam@ravnborg.org
To: Andi Kleen <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:41235 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753133AbXKVD4f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Nov 2007 22:56:35 -0500
In-Reply-To: <20071122343.446909000@suse.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 22 November 2007 13:43:06 Andi Kleen wrote:
> There seems to be rough consensus that the kernel currently has too many
> exported symbols. A lot of these exports are generally usable utility
> functions or important driver interfaces; but another large part are
> functions intended by only one or two very specific modules for a very
> specific purpose.

Hi Andi,

    This is an interesting idea, thanks for the code!  My only question is 
whether we can get most of this benefit by dropping the indirection of 
namespaces and have something like "EXPORT_SYMBOL_TO(sym, modname)"?  It
doesn't work so well for exporting to a group of modules, but that seems
a reasonable line to draw anyway.

Cheers,
Rusty.
PS.  Probably better to use the standard warnx and errx in modpost, too.
