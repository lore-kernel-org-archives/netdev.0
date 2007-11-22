From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH RFC] [1/9] Core module symbol namespaces code and intro.
Date: Thu, 22 Nov 2007 12:46:23 +0100
Message-ID: <200711221246.23994.ak@suse.de>
References: <20071122343.446909000@suse.de> <200711221456.22297.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sam@ravnborg.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:59602 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751596AbXKVLv1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Nov 2007 06:51:27 -0500
In-Reply-To: <200711221456.22297.rusty@rustcorp.com.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 22 November 2007 04:56, Rusty Russell wrote:

>     This is an interesting idea, thanks for the code!  My only question is
> whether we can get most of this benefit by dropping the indirection of
> namespaces and have something like "EXPORT_SYMBOL_TO(sym, modname)"?  It
> doesn't work so well for exporting to a group of modules, but that seems
> a reasonable line to draw anyway.

That would explode quickly already even for my example "inet" namespace.
It already has several modules.  I don't think so much duplication would be a 
good idea.

-Andi
