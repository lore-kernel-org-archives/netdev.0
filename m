From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] kernel memory leak fix for af_unix datagram getpeersec
 patch
Date: Wed, 02 Aug 2006 14:32:04 -0700 (PDT)
Message-ID: <20060802.143204.16511279.davem@davemloft.net>
References: <20060802.141103.35507776.davem@davemloft.net>
	<OF2188FBCE.E3CAA317-ON852571BE.00749BCD-852571BE.0074B02B@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp-2
Content-Transfer-Encoding: 7bit
Cc: catalin.marinas@gmail.com, cxzhang@watson.ibm.com,
	czhang.us@gmail.com, jmorris@namei.org,
	linux-kernel@vger.kernel.org, michal.k.k.piotrowski@gmail.com,
	netdev@vger.kernel.org, sds@tycho.nsa.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:13986
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932203AbWHBVbz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Aug 2006 17:31:55 -0400
To: cxzhang@us.ibm.com
In-Reply-To: <OF2188FBCE.E3CAA317-ON852571BE.00749BCD-852571BE.0074B02B@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xiaolan Zhang <cxzhang@us.ibm.com>
Date: Wed, 2 Aug 2006 17:14:31 -0400

> I will remember this in the future, I promise.

Can you also remember to test your patches with CONFIG_SECURITY
disabled, as you also promised in the past several times?!??!?!

In file included from init/main.c:34:
include/linux/security.h: In function $,1rx(Bsecurity_release_secctx$,1ry(B:
include/linux/security.h:2757: warning: $,1rx(Breturn$,1ry(B with a value, in function returning void

I'll fix this one up, but this is getting rediculious.
