From: Rick Jones <rick.jones2@hp.com>
Subject: Re: e1000 tcp checksum incorrect, x86 64b
Date: Fri, 28 Sep 2007 09:35:07 -0700
Message-ID: <46FD2D3B.4050605@hp.com>
References: <E1Ib79E-0006CN-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jon Smirl <jonsmirl@gmail.com>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:38387 "EHLO palrel10.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751313AbXI1Qf2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Sep 2007 12:35:28 -0400
In-Reply-To: <E1Ib79E-0006CN-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> Jon Smirl <jonsmirl@gmail.com> wrote:
> 
>>App is writing seven bytes to the socket. Socket write timeout expires
>>and the seven bytes are sent. The checksum is not getting inserted
>>into the packet. It is set to a constant 0x8389 instead of the right
>>value.  App is gmpc 0.15.4.95, Revision: 6794
>>
>>Attached Wireshark packet trace show the problem. e1000 is 192.168.1.4
>>64bit, Q6600. Dell Dimension 9200
> 
> 
> Wireshark is broken.  It needs to know TP_STATUS_CSUMNOTREADY
> means that the checksum is partial and will only be completed
> when the hardware sends the packet out.
> 
> Alternatively disable checksum offload with ethtool.

Or take the packet traces "outboard" of the NIC somewhere/somehow.

What problem(s) led to your taking the packet trace in the first place?

rick jones
