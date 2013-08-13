From: Thomas Martitz <thomas.martitz@hhi.fraunhofer.de>
Subject: Re: Preferred method for configuration
Date: Tue, 13 Aug 2013 14:13:34 +0200
Message-ID: <520A22EE.8040006@hhi.fraunhofer.de>
References: <52032D5E.6070307@hhi.fraunhofer.de> <1375940480.2424.135.camel@joe-AO722> <520332F4.5020206@hhi.fraunhofer.de> <20130808090111.241a2043@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.HHI.FRAUNHOFER.DE ([193.174.67.45]:37512 "EHLO
	mailgw.hhi.fraunhofer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757730Ab3HMMNF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 08:13:05 -0400
In-Reply-To: <20130808090111.241a2043@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 08.08.2013 18:01, schrieb Stephen Hemminger:
> On Thu, 08 Aug 2013 07:56:04 +0200
> Thomas Martitz <thomas.martitz@hhi.fraunhofer.de> wrote:
>
>> Resent with list in CC.
>>
>> Am 08.08.2013 07:41, schrieb Joe Perches:
>>> On Thu, 2013-08-08 at 07:32 +0200, Thomas Martitz wrote:
>>>> Hello,
>>>>
>>>> I'm developing a NIC driver and currently export some custom
>>>> configuration settings and actions (e.g. enabling a loopback mode) via
>>>> sysfs.
>>>
>>> Is there some reason you don't want to use ethtool?
>>>
>>>
>>
>> It doesn't allow for custom settings does it? For standards stuff I'm
>> sure going to use ethtool.
>
> Any feature "special to my driver" is sure to meet stiff resistance
> from the kernel developers. Special features make it impossible for generic
> configuration in distributions and by management layers.
>

What about features that are really unique to the device?

Best regards.
