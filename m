From: Shirley Ma <xma@us.ibm.com>
Subject: Re: InfiniBand/RDMA merge plans for 2.6.24
Date: Thu, 13 Sep 2007 11:22:16 -0700
Message-ID: <OF79F6C618.02039854-ON87257355.00646A35-88257355.0064AB34@us.ibm.com>
References: <adahclymos8.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: general@lists.openfabrics.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:49098 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754106AbXIMSWW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2007 14:22:22 -0400
In-Reply-To: <adahclymos8.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Roland,
 
        Since ehca can support 4K MTU, we would like to see a patch in 
IPoIB to allow link MTU to be up to 4K instead of current 2K for 2.6.24 
kernel. The idea is IPoIB link MTU will pick up a return value from SM's 
default broadcast MTU. This patch should be a small patch, I hope you are 
OK with this.

Thanks
Shirley
