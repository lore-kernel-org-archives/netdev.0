From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] e1000e: Remove unused or empty labels
Date: Wed, 08 Aug 2007 18:18:52 -0400
Message-ID: <46BA414C.1050602@garzik.org>
References: <20070808172152.12223.94635.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, netdev@vger.kernel.org, john.ronciak@intel.com
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:44907 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755418AbXHHWS6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Aug 2007 18:18:58 -0400
In-Reply-To: <20070808172152.12223.94635.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> Remove labels with only return, remove E1000_SUCCESS code and
> replace with 0. Remove most goto's.
> 
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  drivers/net/e1000e/82571.c   |  138 +++++---------
>  drivers/net/e1000e/defines.h |    1 
>  drivers/net/e1000e/es2lan.c  |  162 +++++++----------
>  drivers/net/e1000e/ich8lan.c |  401 +++++++++++++++++-------------------------
>  drivers/net/e1000e/lib.c     |  314 +++++++++++++--------------------
>  drivers/net/e1000e/netdev.c  |    4 
>  drivers/net/e1000e/phy.c     |  278 ++++++++++++-----------------
>  7 files changed, 521 insertions(+), 777 deletions(-)

applied all three patches to #e1000e


