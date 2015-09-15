From: David Miller <davem@davemloft.net>
Subject: Re: [net-next:master 6/12] include/linux/usb/cdc.h:23: error:
 redefinition of 'struct usb_cdc_parsed_header'
Date: Tue, 15 Sep 2015 13:27:42 -0700 (PDT)
Message-ID: <20150915.132742.739418011603329556.davem@davemloft.net>
References: <201509160310.FiynyPOo%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oneukum@suse.com, kbuild-all@01.org, netdev@vger.kernel.org
To: fengguang.wu@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53540 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752292AbbIOU1o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2015 16:27:44 -0400
In-Reply-To: <201509160310.FiynyPOo%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: kbuild test robot <fengguang.wu@intel.com>
Date: Wed, 16 Sep 2015 03:57:11 +0800

> All error/warnings (new ones prefixed by >>):
> 
>    In file included from drivers/usb/gadget/function/u_ether.h:20,
>                     from drivers/usb/gadget/legacy/cdc2.c:16:
>    include/linux/usb/cdc.h:47: warning: 'struct usb_interface' declared inside parameter list
>    include/linux/usb/cdc.h:47: warning: its scope is only this definition or declaration, which is probably not what you want
>    In file included from drivers/usb/gadget/function/u_serial.h:16,
>                     from drivers/usb/gadget/legacy/cdc2.c:17:
>>> include/linux/usb/cdc.h:23: error: redefinition of 'struct usb_cdc_parsed_header'
>    include/linux/usb/cdc.h:47: warning: 'struct usb_interface' declared inside parameter list
>>> include/linux/usb/cdc.h:47: error: conflicting types for 'cdc_parse_cdc_header'
>    include/linux/usb/cdc.h:47: error: previous declaration of 'cdc_parse_cdc_header' was here

This may be a side effect of the initial warning, does this reproduce with
that fixed?  Please show me what the warning looks like in that case.

Thanks.
