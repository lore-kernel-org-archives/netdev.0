From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH (resend)][EBTABLES]: Fix alignment checks in	ebt_among.ko
 module.
Date: Mon, 03 Mar 2008 11:50:31 +0300
Message-ID: <47CBBBD7.8070300@openvz.org>
References: <47C7C23C.2050100@openvz.org>  <47C7FF31.1060108@trash.net> <1204470773.2919.9.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Bart De Schuymer <bdschuym@pandora.be>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1204470773.2919.9.camel@localhost.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bart De Schuymer wrote:
> Op vr, 29-02-2008 te 13:48 +0100, schreef Patrick McHardy:
>> Pavel Emelyanov wrote:
>>> I've sent this patch some days ago to Bart, but with no answer...
> 
> Sorry about that.
> 
>>> When trying to do
>>>
>>> 	# ebtables -A FORWARD --among-src 0:12:34:56:78:9a=192.168.0.10 -j ACCEPT
>>>
>>> on x86_64 box the ebt_among->check() callback warns me that
>>>
>>> 	ebtables: among: wrong size: 1060 against expected 1056, rounded to 1056
>>>
>>> So the suggested fix is to move the alignment in the kernel. After
>>> the fix the rule is added and appears in the ebtables -L output.
>>
>> It seems the kernel is correct and userspace is doing it
>> wrong, so I think userspace should be fixed instead.
>> The problem with your patch is that is causes misalignment
>> for following structures that contain u64 members.
> 
> Pavel, please try the attached userspace patch to see if it fixes the
> problem (and let me know the result).

Tested - works OK. Thanks.

> cheers,
> Bart
> 
> 

