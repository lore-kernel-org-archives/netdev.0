From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] isdn: remove deprecated ISDN_CAPI_CAPIFS
Date: Wed, 06 Apr 2011 13:12:16 -0700 (PDT)
Message-ID: <20110406.131216.15250040.davem@davemloft.net>
References: <1302080739-4029-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, isdn@linux-pingi.de, jan.kiszka@web.de
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51629
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755015Ab1DFUMx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 16:12:53 -0400
In-Reply-To: <1302080739-4029-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amerigo Wang <amwang@redhat.com>
Date: Wed,  6 Apr 2011 17:05:39 +0800

> Cc: Jan Kiszka <jan.kiszka@web.de>
> Cc: Karsten Keil <isdn@linux-pingi.de>
> Signed-off-by: WANG Cong <amwang@redhat.com>

capi.c still includes capifs.h, which you are deleting here.

How did you build test this?
