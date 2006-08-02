From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] kernel memory leak fix for af_unix datagram getpeersec
 patch
Date: Wed, 02 Aug 2006 15:19:06 -0700 (PDT)
Message-ID: <20060802.151906.21953222.davem@davemloft.net>
References: <20060802.143204.16511279.davem@davemloft.net>
	<OF4882A75D.C66DD3D0-ON852571BE.007A0271-852571BE.007A82C3@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: catalin.marinas@gmail.com, cxzhang@watson.ibm.com,
	czhang.us@gmail.com, jmorris@namei.org,
	linux-kernel@vger.kernel.org, michal.k.k.piotrowski@gmail.com,
	netdev@vger.kernel.org, sds@tycho.nsa.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:37505
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932277AbWHBWTJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Aug 2006 18:19:09 -0400
To: cxzhang@us.ibm.com
In-Reply-To: <OF4882A75D.C66DD3D0-ON852571BE.007A0271-852571BE.007A82C3@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xiaolan Zhang <cxzhang@us.ibm.com>
Date: Wed, 2 Aug 2006 18:18:07 -0400

> I did test it with CONFIG_SECURITY disabled, but did not catch the warning 
> -- I verified that the build completes with a valid vmlinux image.  There 
> are many warnings (device drivers, and others) during the build and I 
> didn't do a grep to find which one is specific to my patch.  Next time 
> I'll do a diff on warnings too.

Some platforms build their platform code under arch/${ARCH}/foo with
-Werror added to CFLAGS, sparc64 is one such platform.  So the build
did break for me.
