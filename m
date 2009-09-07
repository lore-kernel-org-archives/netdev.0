From: Xiaofei Wu <xiaofei_wu08@yahoo.com>
Subject: Re: [iproute2] tc action mirred    question
Date: Mon, 7 Sep 2009 05:38:49 -0700 (PDT)
Message-ID: <749852.6581.qm@web111606.mail.gq1.yahoo.com>
References: <210469.98452.qm@web111611.mail.gq1.yahoo.com> <1252260806.4580.6.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux netdev <netdev@vger.kernel.org>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from web111606.mail.gq1.yahoo.com ([67.195.23.48]:41526 "HELO
	web111606.mail.gq1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750951AbZIGMir (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2009 08:38:47 -0400
In-Reply-To: <1252260806.4580.6.camel@dogo.mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>





>> On node A,
>> wlan0, IP address 192.168.1.1/24 ; wlan1, IP address 192.168.2.1/24
>> I use command 'tc filter add dev wlan0 ... match ip src 192.168.1.0/24 ...
>> action mirred egress mirror dev wlan1' to mirror packets.
>> When I use 'tcpdump -i wlan1', I can 'see' the packets  'A(wlan0)->B' (node B will forward them to C). 
>> How to forward the mirroring packets 'A(wlan1)' to D (then, node D forwards them to C) ?
>> 
>> 

>Is there a trick to this question or is it too basic? ;-> 

I am sorry.
Maybe it is very easy for you. But I didn't find enough documents(or examples) about 'tc' to help me.
I just want to know:
1) Could I forward the mirroring packets to another node ,and then route it to the destination(if I use 
iproute2 (ip, tc ...)  )?  I described my purpose in my last email.
2)  After I mirrored the packets, I should use 'ip route' , 'ip rule' to modify route tables.  Is this right?

>You should repeat the same on wlan1 to mirror to wlan0 i.e on wlan1:
>match ip src 192.168.2.0/24 ...
>action mirred egress mirror dev wlan0

Would this cause loops?


>Note the  node C will receive "wrong" src mac addresses on those
>interfaces; you may want to correct/edit them first before you send them
>out. Look at using the pedit action.


Regards,
Wu


      
