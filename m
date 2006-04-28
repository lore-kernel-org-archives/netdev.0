From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Fri, 28 Apr 2006 12:10:52 -0700 (PDT)
Message-ID: <20060428.121052.39249337.davem@davemloft.net>
References: <54AD0F12E08D1541B826BE97C98F99F143B0F3@NT-SJCA-0751.brcm.ad.broadcom.com>
	<20060428101833.2f0d6ae8@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: caitlinb@broadcom.com, johnpol@2ka.mipt.ru, kelly@au1.ibm.com,
	rusty@rustcorp.com.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:20109
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751801AbWD1TMH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Apr 2006 15:12:07 -0400
To: shemminger@osdl.org
In-Reply-To: <20060428101833.2f0d6ae8@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Fri, 28 Apr 2006 10:18:33 -0700

> Please just use existing AIO interface.

I totally disagree, the existing AIO interface is garbage.

We need new APIs to do this right, to get the ring buffer
and the zero-copy'ness correct.
