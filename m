From: David Miller <davem@davemloft.net>
Subject: Re: [take2 1/4] kevent: core files.
Date: Wed, 02 Aug 2006 00:25:05 -0700 (PDT)
Message-ID: <20060802.002505.34764840.davem@davemloft.net>
References: <11544248451203@2ka.mipt.ru>
	<44CFEA4B.3060200@oracle.com>
	<20060802063918.GB6378@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zach.brown@oracle.com, linux-kernel@vger.kernel.org,
	drepper@redhat.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:56542
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751320AbWHBHY6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Aug 2006 03:24:58 -0400
To: johnpol@2ka.mipt.ru
In-Reply-To: <20060802063918.GB6378@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Wed, 2 Aug 2006 10:39:18 +0400

> u64 is not aligned, so I prefer to use u32 as much as possible.

We have aligned_u64 exactly for this purpose, netfilter makes
use of it to avoid the x86_64 vs. x86 u64 alignment discrepency.
