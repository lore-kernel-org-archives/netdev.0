From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: New commands to configure IOV features
Date: Mon, 09 Jul 2012 15:13:41 -0600
Message-ID: <4FFB4985.3040507@genband.com>
References: <4FA7AF62.8000405@broadcom.com>	 <20120507081634.000003f8.gregory.v.rose@intel.com>	 <4FE9A963.7020602@broadcom.com> <20120626101903.0000791c@unknown> <1341859155.2535.43.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Greg Rose <gregory.v.rose@intel.com>,
	Yuval Mintz <yuvalmin@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og106.obsmtp.com ([64.18.2.165]:60793 "EHLO
	exprod7og106.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751031Ab2GIVOc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 17:14:32 -0400
In-Reply-To: <1341859155.2535.43.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/09/2012 12:39 PM, Ben Hutchings wrote:
> On Tue, 2012-06-26 at 10:19 -0700, Greg Rose wrote:
>> On Tue, 26 Jun 2012 15:21:55 +0300
>> Yuval Mintz<yuvalmin@broadcom.com>  wrote:
>>
>>> On 05/07/2012 06:16 PM, Greg Rose wrote:
>>>> The only way to configure the number of VFs continues to be through
>>>> the max_vfs module parameter.  I've got a patch to do it through
>>>> ethtool sitting on the back burner but due to other requirements of
>>>> my day job I've not been able to work on it since last fall.
>>>>
>>>> - Greg
>>>
>>>
>>> Hi Ben,
>>>
>>> If I want to pick the RFCs and add support for configuring the number
>>> of VFs - do you think ethtool's the right place for such added
>>> support?
>>>
>>> I'm asking since as far as I can see, ethtool (today) doesn't contain
>>> any features related to virtual functions.
>>
>> I think a PCI utility tool would be better, SR-IOV is not limited to
>> network devices.  That's one of the reasons I dropped the RFC.  I
>> haven't gotten back to the idea since then due to my day job keeping me
>> pretty busy.
>
> For what it's worth, I agree with this.

I'd love to have the ability to set the number of VFs on the fly.   From 
my perspective it would be ideal if this could be exported via /sys or 
something rather than a standalone tool using a binary API.  It's fewer 
packages for userspace to deal with as well as being easily scripted.

Chris
