From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH-2.6.28] net: ipg.c fix bracing on endian swapping
Date: Wed, 19 Nov 2008 15:54:46 -0800 (PST)
Message-ID: <20081119.155446.233089683.davem@davemloft.net>
References: <1226958129.6150.10.camel@brick>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org
To: harvey.harrison@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42021
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751733AbYKSXyq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2008 18:54:46 -0500
In-Reply-To: <1226958129.6150.10.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>
Date: Mon, 17 Nov 2008 13:42:09 -0800

> rxfd->frag_info is a __le64, IPG_RFI_FRAGLEN is a cpu-endian
> constant and wants to be outside of the le64_to_cpu. Fixed
> in multiple places.
> 
> Also an occurrence where le64_to_cpu was used instead of cpu_to_le64
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>

Applied, thanks.
