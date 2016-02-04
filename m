From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next v5 1/2] ethtool: add speed/duplex validation
 functions
Date: Thu, 4 Feb 2016 12:02:48 +0100
Message-ID: <56B32FD8.7020407@cumulusnetworks.com>
References: <1454468677-12280-1-git-send-email-razor@blackwall.org>
 <1454468677-12280-2-git-send-email-razor@blackwall.org>
 <20160204103226.333d98ca@samsung9>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com, roopa@cumulusnetworks.com,
	davem@davemloft.net
To: Stephen Hemminger <stephen@networkplumber.org>,
	Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:34832 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754833AbcBDLCu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 06:02:50 -0500
Received: by mail-wm0-f51.google.com with SMTP id r129so205912493wmr.0
        for <netdev@vger.kernel.org>; Thu, 04 Feb 2016 03:02:50 -0800 (PST)
In-Reply-To: <20160204103226.333d98ca@samsung9>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/04/2016 12:32 AM, Stephen Hemminger wrote:
> On Wed,  3 Feb 2016 04:04:36 +0100
> Nikolay Aleksandrov <razor@blackwall.org> wrote:
> 
>>  
>> +static inline int ethtool_validate_speed(__u32 speed)
>> +{
> 
> 
> No need for inline.
> 
This is defined in a header, if it's not inline you start getting
"defined but not used" warnings.

> But why check for valid value at all. At some point in the
> future, there will be yet another speed adopted by some standard body
> and the switch statement would need another value.
> 
> Why not accept any value? This is a virtual device.
> 
It was moved near the defined values so everyone adding a new speed would
remember to update the validation function as well. That being said, I don't
object to being able to set any custom speed to the virtio_net device especially
when there're physical devices that can have speeds outside of these defines.

Michael do you have any objections if I respin without the speed validation ?

Thanks,
 Nik
