From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [IPV6] addrconf: Fix IPv6 on tuntap tunnels
Date: Sat, 16 Jun 2007 14:33:15 +0200
Message-ID: <4673D88B.5000805@hartkopp.net>
References: <20070614.130358.90120374.davem@davemloft.net>	<467259DD.7030703@hartkopp.net>	<4672F9AE.6070400@hp.com> <20070615.151457.98556461.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: vladislav.yasevich@hp.com, herbert@gondor.apana.org.au,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	koster@debian.org.tw, socketcan@hartkopp.net,
	urs@isnogud.escape.de, florz@florz.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:45684 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754662AbXFPMd4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jun 2007 08:33:56 -0400
In-Reply-To: <20070615.151457.98556461.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Vlad Yasevich <vladislav.yasevich@hp.com>
> Date: Fri, 15 Jun 2007 16:42:22 -0400
>
>   
>> No, the questions should really be:
>>
>> 1.  Is IPV6 supported over this media type.
>> 	yes: got to 2
>> 	no:  stop
>>
>> 2.  Is the device MTU >= IPV6_MIN_MTU
>> 	yes: continue
>> 	no:  stop
>>
>> Autoconfiguration is a layer on top of IPv6.  Whether it's enabled
>> or not should not dictate whether IPv6 addressed may be configured or not.
>>     
>
> Sounds good to me, patches? :-)
>   

Yes, to me it sounds also very good.
I'm not that deep in IPv6 and i do not know about all the media types
that support IPv6, e.g. if a whitelist (as i suggested) is the better
way - or a blacklist.
So i would just support the request from David for patches :-)

Best regards,
Oliver


