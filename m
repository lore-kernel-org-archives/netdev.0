From: Rick Jones <rick.jones2@hp.com>
Subject: Re: udp packet not reach application
Date: Mon, 29 Apr 2013 09:26:31 -0700
Message-ID: <517E9F37.3090304@hp.com>
References: <517AC60F.9010609@gmail.com> <517E7746.6040802@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Min Wang <ser.basis@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:14178 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752454Ab3D2Q0c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 12:26:32 -0400
In-Reply-To: <517E7746.6040802@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

What does netstat -s say in the UDP and IP sections?

What does tcpdump say about the checksums of the incoming UDP datagrams 
which are not being given to your application?

If you happen to send a UDP datagram from the local host to your 
application, is it received?  That is, sending a UDP datagram to your 
application via some path that does not go through this NIC?

Does your NIC claim to support checksum offload?

Just what is your NIC?

rick jones
