From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] e1000e: Simplify MSI interrupt testing
Date: Tue, 14 Sep 2010 14:29:49 -0700 (PDT)
Message-ID: <20100914.142949.184836973.davem@davemloft.net>
References: <201009131045.40018.jdelvare@suse.de>
	<AANLkTikhxka-HHX+SWMpXHcANZCMzedEz+XyiwmF48AK@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jdelvare@suse.de, bruce.w.allan@intel.com, netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52921
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752930Ab0INV3b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Sep 2010 17:29:31 -0400
In-Reply-To: <AANLkTikhxka-HHX+SWMpXHcANZCMzedEz+XyiwmF48AK@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 13 Sep 2010 23:34:54 -0700

> On Mon, Sep 13, 2010 at 01:45, Jean Delvare <jdelvare@suse.de> wrote:
>> The code is quite convoluted, simplify it. This also avoids calling
>> e1000_request_irq() without testing the value it returned, which was
>> bad.
>>
>> Signed-off-by: Jean Delvare <jdelvare@suse.de>
>> Cc: Bruce Allan <bruce.w.allan@intel.com>
> 
> Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> 
> FYI - Emil tested this while I was out, and all was good.  Sorry for
> the delayed response Jean.

Applied, thanks a lot.
