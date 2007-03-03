From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] bridge: avoid ptype_all packet handling
Date: Fri, 02 Mar 2007 23:09:14 -0800
Message-ID: <45E91F1A.6050705@linux-foundation.org>
References: <45E6802C.2090708@linux-foundation.org>	<20070228.233034.74746721.davem@davemloft.net>	<p733b4ncbui.fsf@bingen.suse.de> <20070302.202211.21926049.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, greearb@candelatech.com,
	bridge@linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:56250 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751187AbXCCHJP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Mar 2007 02:09:15 -0500
In-Reply-To: <20070302.202211.21926049.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Andi Kleen <andi@firstfloor.org>
> Date: 03 Mar 2007 03:14:29 +0100
>
>   
>> That's pretty common with many x86 server boards because 
>> they come with two NICs by default but must people only
>> plug the cable into one. However the distro installers
>> run DHCP on all.
>>     
>
> Nope, that's not what I've seen them do, instead they run dhcp on
> interfaces that report a link being present.
>   

Actually, It may be even simpler... I start bridge with a script and 
there was still a dhclient
left over running on the original interface.  It was an interesting 
exercise, and I have new
tools to help, but still no magic bullet to get up to full line rate.
