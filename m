From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: SIOCGIWSCAN wireless event behaviour
Date: Thu, 20 Apr 2006 09:39:07 -0700
Message-ID: <20060420163907.GD1321@instant802.com>
References: <4447979F.4050603@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jt@hpl.hp.com, softmac-dev@sipsolutions.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-28.dex002.intermedia.net ([64.78.21.113]:10946 "EHLO
	dhost002-28.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1751083AbWDTQjU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Apr 2006 12:39:20 -0400
To: Daniel Drake <dsd@gentoo.org>
Content-Disposition: inline
In-Reply-To: <4447979F.4050603@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 20, 2006 at 03:15:59PM +0100, Daniel Drake wrote:

> I think the 'extra' SIOCGIWSCAN event may be confusing wpa_supplicant 
> (but have not confirmed that yet).

No, they don't. madwifi-ng is already doing this with background
scanning and as was pointed out, there can be multiple programs asking
for scans, so user space must be prepared for multiple events anyway.

-- 
Jouni Malinen                                            PGP id EFC895FA
