From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [Cbe-oss-dev] [RFC][PATCH] spidernet: enable fiber autonegotiation
Date: Mon, 27 Nov 2006 16:05:12 +0100
Message-ID: <200611271605.12784.arnd@arndb.de>
References: <200611271547.07433.jens@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jens Osterkamp <jens@de.ibm.com>, netdev@vger.kernel.org,
	jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:38110 "EHLO
	moutng.kundenserver.de") by vger.kernel.org with ESMTP
	id S1758271AbWK0PF1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Nov 2006 10:05:27 -0500
To: cbe-oss-dev@ozlabs.org
In-Reply-To: <200611271547.07433.jens@de.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 27 November 2006 15:47, Jens Osterkamp wrote:
> 
> While experimenting with a copper passthrough module in bladecenter I found 
> out that this needs autonegotiation enabled in order to work properly.
> This quick hack enables it with the sideeffect of breaking other bladecenter 
> switch configurations.
> If anyone has any suggestions or has experimented with the same configuration, 
> feel free to comment.

There was a patch from Ishizaki Kou recently, to set up autonegotiate
and other things, see http://patchwork.ozlabs.org/linuxppc/patch?id=8121 .

Are you sure that you don't need any of those changes as well?

	Arnd <><
