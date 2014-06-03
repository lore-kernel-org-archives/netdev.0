From: Ben Greear <greearb@candelatech.com>
Subject: Re: Trying to ping from a subinterface.
Date: Mon, 02 Jun 2014 21:13:51 -0700
Message-ID: <538D4B7F.4080302@candelatech.com>
References: <538CE2CA.9060806@us.thalesgroup.com> <20140602173554.1dc77101@nehalam.linuxnetplumber.net> <538D19C9.3090801@us.thalesgroup.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: CLOSE Dave <Dave.Close@us.thalesgroup.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:37081 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750915AbaFCENx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 00:13:53 -0400
In-Reply-To: <538D19C9.3090801@us.thalesgroup.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 06/02/2014 05:41 PM, CLOSE Dave wrote:
> Stephen Hemminger wrote (in response to my complaint):
>
>>>> # ping -I eth3:sub1 172.17.30.1
>>>> ping: SO_BINDTODEVICE: Invalid argument
>
>> Interface aliases (sub interfaces) aren't real interfaces in Linux.
>> They are a deprecated way of doing multiple addresses on the same
>> device. Aliases aren't real devices, they don't behave like devices,
>> and they only are useful with ancient tools like ifconfig.
>>
>> Don't use them unless you have to deal with systems older than 10
>> years.
>
> I apologize to the group. I had been led to believe this was working on
> earlier Fedora releases. In fact, it was complaining but then falling
> back to the main interface and performing the ping anyway. What is new
> is the refusal to fall back.
>
> Starting fresh, I'd agree with your suggestion. But there is a lot of
> legacy code in the world...

SO_BINDTODEVICE could never work on sub-interfaces as far as I know,
but maybe older versions of ping just didn't bother doing SO_BINDTODEVICE.

Do you actually need sub-interfaces for some reason, or can you just use
multiple IPs on one interface (or maybe mac-vlans)?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
