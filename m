From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix IGMPV3_EXP() normalization bit shift value
Date: Sun, 19 Nov 2006 13:40:14 -0500 (EST)
Message-ID: <20061119.134014.74732638.davem@davemloft.net>
References: <OF53C62317.D1729E3A-ON88257229.0008EA38-88257229.000A067D@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from localhost.localdomain ([127.0.0.1]:62862 "EHLO localhost")
	by vger.kernel.org with ESMTP id S932799AbWKSSkO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Nov 2006 13:40:14 -0500
To: dlstevens@us.ibm.com
In-Reply-To: <OF53C62317.D1729E3A-ON88257229.0008EA38-88257229.000A067D@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Stevens <dlstevens@us.ibm.com>
Date: Thu, 16 Nov 2006 18:49:30 -0700

> The IGMPV3_EXP() macro doesn't correctly shift the normalization bit, so
> time-out values are longer than they should be. Patch below for viewing
> and attached for applying.
> 
> Thanks to Dirk Ooms for finding the problem in IGMPv3 - MLDv2 had a
> similar problem that was already fixed a year ago. :-(
> 
>                                                 +-DLS
> 
> Signed-off-by: David L Stevens <dlstevens@us.ibm.com>

Applied, and pushed to -stable.  Thanks David.
