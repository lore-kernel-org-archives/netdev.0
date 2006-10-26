From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [RFC] tcp: setsockopt congestion control autoload
Date: Thu, 26 Oct 2006 07:34:57 -0700
Message-ID: <4540C791.5060200@osdl.org>
References: <20061025110843.0cbd18a7@freekitty> <20061026052253.GA10188@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:14303 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1423360AbWJZOfK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2006 10:35:10 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20061026052253.GA10188@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> On Wed, Oct 25, 2006 at 11:08:43AM -0700, Stephen Hemminger (shemminger@osdl.org) wrote:
>   
>> If user asks for a congestion control type with setsockopt() then it
>> may be available as a module not included in the kernel already. 
>> It should be autoloaded if needed.  This is done already when
>> the default selection is change with sysctl, but not when application
>> requests via sysctl.
>>
>> Only reservation is are there any bad security implications from this?
>>     
>
> What if system is badly configured, so it is possible to load malicious
> module by kernel?
>
>   
The kernel module loader has a fixed path. So one would have to be able 
to create a module
in /lib/modules/<kernel release> in order to get the malicious code 
loaded.  If the intruder could
put a module there, it would be just as easy to patch an existing module 
and have the
hack available on reboot.
