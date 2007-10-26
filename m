From: Florin Andrei <florin@andrei.myip.org>
Subject: Re: stateless 1:1 NAT
Date: Fri, 26 Oct 2007 10:49:15 -0700
Message-ID: <4722289B.9080704@andrei.myip.org>
References: <E1IhxQo-0004hF-00@gondolin.me.apana.org.au> <4716510E.3090300@andrei.myip.org> <4716661B.3020301@trash.net>
Reply-To: netdev@vger.kernel.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp121.sbc.mail.sp1.yahoo.com ([69.147.64.94]:36806 "HELO
	smtp121.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751639AbXJZRtU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2007 13:49:20 -0400
Received: from localhost (weiqi.home.local [127.0.0.1])
	by weiqi.home.local (Postfix) with ESMTP id 94CF6577054
	for <netdev@vger.kernel.org>; Fri, 26 Oct 2007 10:49:17 -0700 (PDT)
Received: from weiqi.home.local ([127.0.0.1])
	by localhost (andrei.myip.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Daot5TvooM6W for <netdev@vger.kernel.org>;
	Fri, 26 Oct 2007 10:49:16 -0700 (PDT)
Received: from valar.sanjose.telcontar.com (unknown [192.168.2.2])
	by weiqi.home.local (Postfix) with ESMTP id 0234D576EE3
	for <netdev@vger.kernel.org>; Fri, 26 Oct 2007 10:49:15 -0700 (PDT)
In-Reply-To: <4716661B.3020301@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Florin Andrei wrote:
>> OpenBSD 4.1 as a firewall fails even worse in this test case (it 
>> freezes instantly).
>> OpenBSD 4.2 works fine under the UDP flood, as if nothing happened.
> 
> And Linux 2.6.23? :)

Same as 2.6.18, actually maybe a little bit worse than .18: the current 
download does not even complete, and of course a new one doesn't start.

I may test 2.6.24 and stateless 1:1 NAT and we'll see what happens. I've 
been told that stateless 1:1 NAT is already in the .24_rc1 so I may test 
that.

-- 
Florin Andrei

http://florin.myip.org/
