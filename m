From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 2.2LK: Low link speed after suspend
Date: Wed, 18 Apr 2007 00:30:27 +0200
Message-ID: <20070417223027.GA9517@electric-eye.fr.zoreil.com>
References: <200704162241.31729.peter.missel@onlinehome.de> <20070416210940.GA13710@electric-eye.fr.zoreil.com> <200704172236.43280.peter.missel@onlinehome.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Peter Missel <peter.missel@onlinehome.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:50180 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161397AbXDQWdQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Apr 2007 18:33:16 -0400
Content-Disposition: inline
In-Reply-To: <200704172236.43280.peter.missel@onlinehome.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Peter Missel <peter.missel@onlinehome.de> :
[...]
> Does this patchset work against kernel 2.6.18, or, better yet, is there a 
> separate source package that lets me build the current driver on this older 
> kernel?

Hardly: the r8169 driver has been modified by ~40 patches from 2.6.18 to now.

There is an ugly hack^W^W quick backport for 2.6.18 at:
http://www.fr.zoreil.com/people/francois/backport/r8169/20070418-00

It compiles but I do not know if it works and I strongly suggest to use
a more recent kernel package anyway.

-- 
Ueimor

Anybody got a battery for my Ultra 10 ?
