From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 2/3] mlsxfrm: Various fixes
Date: Wed, 8 Nov 2006 23:38:39 -0500 (EST)
Message-ID: <Pine.LNX.4.64.0611082337520.5916@d.namei>
References: <000501c70342$83b9df70$cc0a010a@tcssec.com> <4552A9AC.3060708@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: vyekkirala@TrustedCS.com, netdev@vger.kernel.org,
	selinux@tycho.nsa.gov, sds@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail7.sea5.speakeasy.net ([69.17.117.9]:7139 "EHLO
	mail7.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1423859AbWKIEin (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Nov 2006 23:38:43 -0500
To: Paul Moore <paul.moore@hp.com>
In-Reply-To: <4552A9AC.3060708@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 8 Nov 2006, Paul Moore wrote:

> 1. Functionality is available right now, no additional kernel changes needed
> 2. No special handling for localhost, I tend to like the idea of having
> consistent behavior for all addresses/interfaces

I don't agree.  SO_PEERSEC should always just work for loopback, just like 
with Unix sockets.



- James
-- 
James Morris
<jmorris@namei.org>
