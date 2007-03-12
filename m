From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 4/4] [TULIP] Rev tulip version
Date: Mon, 12 Mar 2007 10:07:33 -0400
Message-ID: <45F55EA5.9080005@garzik.org>
References: <20070312093128.577087000@linux.intel.com>	 <20070312095912.743760000@linux.intel.com> <84144f020703120344n3f5ed52axf0bc1c109b549535@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Valerie Henson <val_henson@linux.intel.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50433 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965490AbXCLOHj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Mar 2007 10:07:39 -0400
In-Reply-To: <84144f020703120344n3f5ed52axf0bc1c109b549535@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pekka Enberg wrote:
> Hi,
> 
> On 3/12/07, Valerie Henson <val_henson@linux.intel.com> wrote:
>> --- tulip-2.6-mm-linux.orig/drivers/net/tulip/tulip_core.c
>> +++ tulip-2.6-mm-linux/drivers/net/tulip/tulip_core.c
>> @@ -17,11 +17,11 @@
>>
>>  #define DRV_NAME       "tulip"
>>  #ifdef CONFIG_TULIP_NAPI
>> -#define DRV_VERSION    "1.1.14-NAPI" /* Keep at least for test */
>> +#define DRV_VERSION    "1.1.15-NAPI" /* Keep at least for test */
>>  #else
>> -#define DRV_VERSION    "1.1.14"
>> +#define DRV_VERSION    "1.1.15"
>>  #endif
>> -#define DRV_RELDATE    "May 11, 2002"
>> +#define DRV_RELDATE    "Feb 27, 2007"
> 
> Why not just drop this? What purpose does a per-module revision have
> for in-kernel drivers anyway?

It's the maintainer's call.  Sometimes it eases parsing bug reports, and 
tracking changes as your drivers get backported to various enterprise 
operating systems(tm).  Sometimes it just gets in the way.

	Jeff



