From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] atm: clip timer race
Date: Fri, 14 Apr 2006 15:56:34 -0700 (PDT)
Message-ID: <20060414.155634.10131729.davem@davemloft.net>
References: <20060412202551.GA20085@gondor.apana.org.au>
	<20060412145254.4dd21be6@localhost.localdomain>
	<20060412154214.1dd4117d@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, chas@cmf.nrl.navy.mil,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:20113
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751359AbWDNW5i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Apr 2006 18:57:38 -0400
To: shemminger@osdl.org
In-Reply-To: <20060412154214.1dd4117d@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Wed, 12 Apr 2006 15:42:14 -0700

> By inspection, the clip idle timer code is racy on SMP.
> Here is a safe version of timer management.
> Untested, I don't have ATM hardware.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Applied, thanks Stephen.
