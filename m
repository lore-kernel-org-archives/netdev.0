From: Florin Andrei <florin@andrei.myip.org>
Subject: Re: stateless 1:1 NAT
Date: Fri, 09 Nov 2007 13:04:48 -0800
Message-ID: <4734CB70.5030402@andrei.myip.org>
References: <E1IkrvI-00046G-00@gondolin.me.apana.org.au>
Reply-To: netdev@vger.kernel.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp119.sbc.mail.sp1.yahoo.com ([69.147.64.92]:23003 "HELO
	smtp119.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751286AbXKIVEw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2007 16:04:52 -0500
Received: from localhost (weiqi.home.local [127.0.0.1])
	by weiqi.home.local (Postfix) with ESMTP id 1B7C7576E38
	for <netdev@vger.kernel.org>; Fri,  9 Nov 2007 13:04:50 -0800 (PST)
Received: from weiqi.home.local ([127.0.0.1])
	by localhost (andrei.myip.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Pr8DlciJVpV2 for <netdev@vger.kernel.org>;
	Fri,  9 Nov 2007 13:04:49 -0800 (PST)
Received: from valar.sanjose.telcontar.com (unknown [192.168.2.2])
	by weiqi.home.local (Postfix) with ESMTP id 00DB6576E37
	for <netdev@vger.kernel.org>; Fri,  9 Nov 2007 13:04:48 -0800 (PST)
In-Reply-To: <E1IkrvI-00046G-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> Florin Andrei <florin@andrei.myip.org> wrote:
>> OK, if I download 2.6.24-rc1, will it have this feature already?
> 
> Yes.

OK, I want to test this feature with 2.6.24-rc2. I compiled 
iproute2-2.6.23 with your patch applied.
The problem is, I have no experience with tc (and very little experience 
with iproute2 in general). Can you give me an example on how to setup 
1:1 NAT for one system?

Let's say, the firewall has the addresses 10.123.0.10 (eth0 outside) and 
10.123.1.10 (eth1 inside), the server behind it is 10.123.1.253 and I 
want to map the server's address to 10.123.0.253 on the outside interface.
What are the parameters for tc to setup 1:1 NAT like that?

-- 
Florin Andrei

http://florin.myip.org/
