From: jamal <hadi@cyberus.ca>
Subject: Re: [iproute2] tc action mirred    question
Date: Mon, 07 Sep 2009 08:54:23 -0400
Message-ID: <1252328063.4533.12.camel@dogo.mojatatu.com>
References: <210469.98452.qm@web111611.mail.gq1.yahoo.com>
	 <1252260806.4580.6.camel@dogo.mojatatu.com>
	 <749852.6581.qm@web111606.mail.gq1.yahoo.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux netdev <netdev@vger.kernel.org>
To: Xiaofei Wu <xiaofei_wu08@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.27]:8412 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752441AbZIGNEg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2009 09:04:36 -0400
Received: by qw-out-2122.google.com with SMTP id 8so665055qwh.37
        for <netdev@vger.kernel.org>; Mon, 07 Sep 2009 06:04:38 -0700 (PDT)
In-Reply-To: <749852.6581.qm@web111606.mail.gq1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-09-07 at 05:38 -0700, Xiaofei Wu wrote:

> I just want to know:
> 1) Could I forward the mirroring packets to another node ,and then route it to the destination(if I use 
> iproute2 (ip, tc ...)  )?  I described my purpose in my last email.

Yes, you can mirror to another node(B/D). To route on that node(B/D),
your dst MAC address has to be correct for that destination node(B/D) to
accept it. You could try to run  the destination node in promisc mode
and you may be able to get away without changing dst mac.

> 2)  After I mirrored the packets, I should use 'ip route' , 'ip rule' to modify route tables.  Is this right?
> 

Assuming you are talking about B/D, yes you can do routing there if the
node accepts it..

> >You should repeat the same on wlan1 to mirror to wlan0 i.e on wlan1:
> >match ip src 192.168.2.0/24 ...
> >action mirred egress mirror dev wlan0
> 
> Would this cause loops?
> 

Ok, so this was the trick question;->
I dont see how the loop would happen - they are different "match" rules
i.e one is for 192.168.2.0/24 and the other is for 192.168.1.0/24
Whether it loops or not is easy for you to verify.

cheers,
jamal

