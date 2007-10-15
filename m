From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] e1000e: fix debugging printout code
Date: Mon, 15 Oct 2007 09:20:32 -0700
Message-ID: <47139350.8010209@intel.com>
References: <20071004183843.31540.23710.stgit@localhost.localdomain>	 <47067A2F.5020603@garzik.org> <1192464021.4556.49.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, Auke Kok <auke-jan.h.kok@intel.com>,
	netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:7799 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754430AbXJOQ0x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Oct 2007 12:26:53 -0400
In-Reply-To: <1192464021.4556.49.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Perches wrote:
> On Fri, 2007-10-05 at 13:53 -0400, Jeff Garzik wrote:
>>> diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
>>> index 848217a..aa82f1a 100644
>>> --- a/drivers/net/e1000e/hw.h
>>> +++ b/drivers/net/e1000e/hw.h
>>> @@ -852,7 +852,7 @@ struct e1000_hw {
>>>  
>>>  #ifdef DEBUG
>>>  #define hw_dbg(hw, format, arg...) \
>>> -	printk(KERN_DEBUG, "%s: " format, e1000_get_hw_dev_name(hw), ##arg);
>>> +	printk(KERN_DEBUG, "%s: " format, e1000e_get_hw_dev_name(hw), ##arg);
>> I will apply this, but, I strongly encourage deletion of this in favor 
>> of the existing dev_dbg()
> 
> Instead the fix should be for the 2 existing bugs on macro:
> 
> o Comma after KERN_DEBUG
> o Semicolon in macro

will push a patch, thanks.

Auke
