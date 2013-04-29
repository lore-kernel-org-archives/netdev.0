From: Min Wang <ser.basis@gmail.com>
Subject: udp packet not reach application
Date: Mon, 29 Apr 2013 09:36:06 -0400
Message-ID: <517E7746.6040802@gmail.com>
References: <517AC60F.9010609@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f170.google.com ([209.85.216.170]:49068 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752062Ab3D2NgK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 09:36:10 -0400
Received: by mail-qc0-f170.google.com with SMTP id d42so3178308qca.29
        for <netdev@vger.kernel.org>; Mon, 29 Apr 2013 06:36:09 -0700 (PDT)
Received: from [192.168.55.254] (173-161-143-17-Philadelphia.hfc.comcastbusiness.net. [173.161.143.17])
        by mx.google.com with ESMTPSA id s10sm12867522qam.7.2013.04.29.06.36.07
        for <netdev@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 29 Apr 2013 06:36:08 -0700 (PDT)
In-Reply-To: <517AC60F.9010609@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

HI

since Linux-net mailing list no longer active, so post here. Hope it is  
the right place.


I have following issue ( kernel 3.2.28), google around, could not find 
any good similar case.

one the host:
     all the  /proc/sys/net/ipv4/conf/*/rp_filter are 0

    a device sent udp traffics to  my udp app ( listen on port x)


At first, it was working as my app did get udp traffic.

After a while, strace showed that my app stuck at recvfrom, no udp traffic.

But tcpdump did show that the udp traffic was still coming/alive.


Even if I restart my app, strace still showed it was stuck at recv_from.


it seems the kernel stop or did not deliver the udp packet to my app at 
some point.


So I have to restart NIC interface, then I could see udp traffic 
received at my app. (strange also?)


What could be wrong? Driver? or Kernel or my app?

At which point the kernel could possibly stop delivering the packets to 
upper layer even though traffic seen from tcpdump?


Thanks a lot!



min
