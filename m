From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH ] cdc_ncm: fixes for big-endian architecture / MIPS
Date: Thu, 04 Aug 2011 01:43:46 -0700 (PDT)
Message-ID: <20110804.014346.1807814282993997292.davem@davemloft.net>
References: <87ipqeebvg.fsf@gnu.org>
	<20110803.191141.888495095889424492.davem@davemloft.net>
	<87fwlhzjey.fsf@gnu.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexey.orishko@stericsson.com, netdev@vger.kernel.org,
	oliver@neukum.org, linux-usb@vger.kernel.org, gregkh@suse.de,
	alexey.orishko@gmail.com
To: giuseppe@southpole.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52445 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751758Ab1HDIoC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Aug 2011 04:44:02 -0400
In-Reply-To: <87fwlhzjey.fsf@gnu.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe Scrivano <giuseppe@southpole.se>
Date: Thu, 04 Aug 2011 10:10:29 +0200

> cdc_ncm: fix endianness problem.
> 
> Fix a misusage of the struct usb_cdc_notification to pass arguments to the
> usb_control_msg function.  The usb_control_msg function expects host endian
> arguments but usb_cdc_notification stores these values as little endian.
> 
> Now usb_control_msg is directly invoked with host endian values.

Applied.
