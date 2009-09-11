From: jamal <hadi@cyberus.ca>
Subject: Re: [iproute2] tc action mirred    question
Date: Fri, 11 Sep 2009 08:25:40 -0400
Message-ID: <1252671940.25158.5.camel@dogo.mojatatu.com>
References: <404956.88336.qm@web111607.mail.gq1.yahoo.com>
	 <1252376168.5244.11.camel@dogo.mojatatu.com>
	 <313388.35529.qm@web111617.mail.gq1.yahoo.com>
	 <1252534266.4119.5.camel@dogo.mojatatu.com>
	 <204967.7557.qm@web111613.mail.gq1.yahoo.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux netdev <netdev@vger.kernel.org>
To: Xiaofei Wu <xiaofei_wu08@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f172.google.com ([209.85.221.172]:54822 "EHLO
	mail-qy0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752119AbZIKM2H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2009 08:28:07 -0400
Received: by qyk2 with SMTP id 2so877435qyk.21
        for <netdev@vger.kernel.org>; Fri, 11 Sep 2009 05:28:09 -0700 (PDT)
In-Reply-To: <204967.7557.qm@web111613.mail.gq1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-09-09 at 23:06 -0700, Xiaofei Wu wrote:
> 


> It seems that I modify the dst MAC, src MAC of the packets,  then transmit to 'lo'  and  mirror the packects to 'eth0'.  
> (On 'lo',  '2616 packets transmitted, 0 received, 100% packet loss' .)  How to let 'lo' receive the packets?

By not modifying the packets. I am a little suprised that changing the
Mac address on lo has that effect.
Note it should work on ingress as i described because ingress doesnt
queue packets.

> 
> But I want to only modify the dst MAC, src MAC of the mirroring packets, transmit them to next hop. 
> (not modify the dst,src MAC of the packets to 'lo').  What should I do?

Ok, so modifying then mirroring wont work on ingress;->
One thing you can try is first to mirror lo->eth0, then pedit only
specific flow on eth0 that came from lo.

cheers,
jamal

