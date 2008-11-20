From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ip_sockglue.c add static, annotate ports'
 endianness
Date: Thu, 20 Nov 2008 01:54:36 -0800 (PST)
Message-ID: <20081120.015436.15790123.davem@davemloft.net>
References: <1227039841.13182.1.camel@brick>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: harvey.harrison@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47426
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752897AbYKTJyg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 04:54:36 -0500
In-Reply-To: <1227039841.13182.1.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>
Date: Tue, 18 Nov 2008 12:24:01 -0800

> Fixes sparse warnings:
> net/ipv4/ip_sockglue.c:146:15: warning: incorrect type in assignment (different base types)
> net/ipv4/ip_sockglue.c:146:15:    expected restricted __be16 [assigned] [usertype] sin_port
> net/ipv4/ip_sockglue.c:146:15:    got unsigned short [unsigned] [short] [usertype] <noident>
> net/ipv4/ip_sockglue.c:130:6: warning: symbol 'ip_cmsg_recv_dstaddr' was not declared. Should it be static?
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> ---
> These are new warnings between next-20081117 and next-20081118

Applied, thanks.
