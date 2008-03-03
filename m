From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: e1000e fails to find IRQ
Date: Mon, 03 Mar 2008 13:49:32 -0800
Message-ID: <47CC726C.4060908@intel.com>
References: <20080303124443.52gfbwwmahxf7wmk@m.safari.iki.fi> <47CC3DF7.20907@intel.com> <20080303190339.wbilb6qaknwvj4sk@m.safari.iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Linux Networking Mailing List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:17485 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754783AbYCCV62 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Mar 2008 16:58:28 -0500
Received: from [127.0.0.1] (localhost [127.0.0.1])
	by ahkok-mobl.jf.intel.com (Postfix) with ESMTP id 704F340373
	for <netdev@vger.kernel.org>; Mon,  3 Mar 2008 13:49:32 -0800 (PST)
In-Reply-To: <20080303190339.wbilb6qaknwvj4sk@m.safari.iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sami Farin wrote:
> On Mon, Mar 03, 2008 at 10:05:43 -0800, Kok, Auke wrote:
>> Sami Farin wrote:
> ..
>>> I have Intel DQ965GF mobo, version CO96510J.86A.6002.2007.1125.2356,
>>> Linux 2.6.24.3.
>> a bit unclear what kernel version you are actually using here... the device that
>> you have (ich8 onboard lan) is NOT supported in 2.6.24.x by e1000e - you'll have
> 
> OK, that was not very clear from "PCI interrupt disabled" message.
> 
>> to use the e1000 driver until 2.6.25 ships.
>>
>> what kernel version are you using here?
> 
> 2.6.24.3.
> 
> I thought I could try e1000e for fun, because e1000 module said:
>   This device (id 8086:104a) will no longer be supported by this driver
>   in the future, please use the "e1000e" driver
> :)
> 

yep, that message is for 2.6.25+ kernels... not 2.6.24

Auke


