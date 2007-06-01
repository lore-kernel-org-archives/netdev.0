From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] fix e100 rx path on ARM (was [PATCH] e100 rx: or s and
 el bits)
Date: Fri, 01 Jun 2007 15:13:41 -0700
Message-ID: <46609A15.4000805@intel.com>
References: <200705011124.l41BOEG4007662@sullivan.realtime.net> <46375664.8030701@roinet.com> <4638F2B2.2000103@roinet.com> <463BA906.30205@roinet.com> <85f07fc58d5ed2147d5214d0f0b4fe32@bga.com> <4648A9DF.6030001@roinet.com> <464D074F.20400@pobox.com> <464D21B6.2000208@intel.com> <464DB336.2030003@roinet.com> <464DB619.3070900@roinet.com> <464DC676.90504@intel.com> <464DCA97.3070405@roinet.com> <464DCD5E.50003@intel.com> <464DDE3E.9010400@roinet.com> <e3819b7a866b1117fd5a69e6a85e0784@bga.com> <4651DAC1.7050604@intel.com> <53c44b6f03973eb1b28f221859d3002c@bga.com> <465369AF.8080508@roinet.com> <f83441453b1233771c5bda869912aeca@bga.com> <4654B2E4.9010308@roinet.com> <039d8ee49a8dfcbff8695b19d0a1a5c4@bga.com> <a4fae96e1c8c7b594207bf77fcb6b38f@bga.com> <465C4DBE.6000205@roinet.com> <94c8ff9069a77568513a9a1d1e60012d@bga.com> <4660856E.80403@roinet.com> <46608BFE.7000905@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Acker <dacker@roinet.com>, Milton Miller <miltonm@bga.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Scott Feldman <sfeldma@pobox.com>, netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:33143 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751710AbXFAWNu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Jun 2007 18:13:50 -0400
In-Reply-To: <46608BFE.7000905@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> David Acker wrote:
>> Milton Miller wrote:

<snip>

>> the el flag but we leave the size was 0 bit set.  This was we can find
>> this buffer again later.
>>
>> If the hardware sees the el-bit cleared without the size set, it will
>> move on to the next buffer and skip this one.  If it sees
>> the size set but the el-bit still set, it will complete that buffer
>> and then RNR interrupt and wait.
>>
>>
>> Signed-off-by: David Acker <dacker@roinet.com>
> 
> That seems to vaguely match my memory of what eepro100 was doing (or 
> trying to do).
> 
> I _really_ appreciate you working on this problem.  Getting e100 driver 
> stable for the long term, and ditching eepro100, is a big hurdle to 
> cross.  Getting this right is really one of the last steps.

yes, absolutely agreed. I'm very pleased with the attention and hope that is 
clear to everyone.

> The patch looks OK at quick glance.

Besides copying the style errors, it looks OK as well. I will attempt to 
allocate some testing time again early next week on a small library of e100 nics 
over here. Mostly x86, but still useful to spot obvious mistakes.


Auke
