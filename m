From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 5/8] net_sched: cls_flow: use proto_ports_offset() to
 support AH message
Date: Wed, 18 Aug 2010 09:53:09 -0400
Message-ID: <1282139589.23601.38.camel@bigi>
References: <1282107908-3585-1-git-send-email-xiaosuo@gmail.com>
	 <1282129364.23601.17.camel@bigi>
	 <AANLkTi=50qHT_-OoMbWcPT1Fi7JEa0e_kReZhnpVJJdR@mail.gmail.com>
	 <1282136070.23601.26.camel@bigi>
	 <AANLkTin9Pm0oPpteYsZsPUEyAj9qMxrSL9k1GXNYeY9h@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:42756 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752752Ab0HRNxN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Aug 2010 09:53:13 -0400
Received: by qyk33 with SMTP id 33so635815qyk.19
        for <netdev@vger.kernel.org>; Wed, 18 Aug 2010 06:53:12 -0700 (PDT)
In-Reply-To: <AANLkTin9Pm0oPpteYsZsPUEyAj9qMxrSL9k1GXNYeY9h@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-08-18 at 21:18 +0800, Changli Gao wrote:

> I had gone through the code before submitting this code. But it isn't
> easy to test if it breaks sth. 

That works well actually and it is the LinuxWay(tm);-> 

> Would you please give a case to test ?

Just conformance testing. Since you added new AH SPI behavior
at least find some use case of what people normally use and make sure it
isnt broken. But if youve looked at code sufficiently i think thats good
enough.

cheers,
jamal

