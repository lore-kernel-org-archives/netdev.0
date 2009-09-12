From: Xiaofei Wu <xiaofei_wu08@yahoo.com>
Subject: Re: [iproute2] tc action mirred    question
Date: Sat, 12 Sep 2009 09:01:42 -0700 (PDT)
Message-ID: <463375.95638.qm@web111612.mail.gq1.yahoo.com>
References: <404956.88336.qm@web111607.mail.gq1.yahoo.com>  <1252376168.5244.11.camel@dogo.mojatatu.com>  <313388.35529.qm@web111617.mail.gq1.yahoo.com>  <1252534266.4119.5.camel@dogo.mojatatu.com>  <204967.7557.qm@web111613.mail.gq1.yahoo.com>  <1252671940.25158.5.camel@dogo.mojatatu.com>  <510605.34044.qm@web111611.mail.gq1.yahoo.com> <1252704524.25158.42.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux netdev <netdev@vger.kernel.org>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from n7.bullet.mail.ac4.yahoo.com ([76.13.13.235]:27624 "HELO
	n7.bullet.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751863AbZILQIU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Sep 2009 12:08:20 -0400
In-Reply-To: <1252704524.25158.42.camel@dogo.mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> I think you are doing something wrong. Are there really packets
>being generated with that source address.
I made a mistake. I changed it to 'match ip src 192.168.1.0/24' . Now it works.

I can mirror the packets (A -> B) to D. Node D forwards them to C.
Sometimes the same packets through the path A-B-C, A-D-C are not lost. Node C will receive the
same packets twice. How to handle the duplicate packet on node C ?

Maybe the duplicate packets have side effects to TCP.



regards,
wu



      

