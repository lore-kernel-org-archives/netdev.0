From: Xiaofei Wu <xiaofei_wu08@yahoo.com>
Subject: Re: [iproute2] tc action mirred    question
Date: Mon, 7 Sep 2009 09:05:47 -0700 (PDT)
Message-ID: <404956.88336.qm@web111607.mail.gq1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux netdev <netdev@vger.kernel.org>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from web111607.mail.gq1.yahoo.com ([67.195.23.49]:40765 "HELO
	web111607.mail.gq1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753739AbZIGQFr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2009 12:05:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I am a newbie for 'traffic control' and Linux networking. So I ask some experts here  to help me.
Maybe my questions are stupid. But I hope I can get your reply. Thank you!


>> I just want to know:
>> 1) Could I forward the mirroring packets to another node ,and then route it to the destination(if I use 
>> iproute2 (ip, tc ...)  )?  I described my purpose in my last email.

>Yes, you can mirror to another node(B/D). To route on that node(B/D),
>your dst MAC address has to be correct for that destination node(B/D) to
>accept it. You could try to run  the destination node in promisc mode
>and you may be able to get away without changing dst mac.

(1) Could I use  pedit action to modify the dst MAC, so the destination node D will accept it, then forward it to 
node C?  (or use other tools to modify the dst MAC, please give me more information)

(2) If I use 'ifconfig wlan0 promisc ... ' on node D, would it route the mirroring packets (the dst MAC is incorrect)
to node C?


>> 2)  After I mirrored the packets, I should use 'ip route' , 'ip rule' to modify route tables.  Is this right?
>> 

>Assuming you are talking about B/D, yes you can do routing there if the
>node accepts it..


Regards,
Wu



      
