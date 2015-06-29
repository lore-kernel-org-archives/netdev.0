From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH RFC net-next] vxlan: GRO support at tunnel layer
Date: Mon, 29 Jun 2015 08:45:57 -0700
Message-ID: <55916835.8030809@hp.com>
References: <1435360189-641007-1-git-send-email-tom@herbertland.com> <558DF24A.1040504@hp.com> <df94e5b8a0ed7a9146063908e3001ef3@imap.linux.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Ramu Ramamurthy <sramamur@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t2353.austin.hp.com ([15.217.128.52]:21428 "EHLO
	g2t2353.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753270AbbF2Pp7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2015 11:45:59 -0400
In-Reply-To: <df94e5b8a0ed7a9146063908e3001ef3@imap.linux.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/28/2015 10:20 AM, Ramu Ramamurthy wrote:
> Rick, in your test, are you seeing gro becoming effective on the
> vxlan interface with the 82599ES nic ? (ie, tcpdump on the vxlan
> interface shows larger frames than the mtu of that interface, and
> kernel trace shows vxlan_gro_receive() being hit)
>
> Throughputs of 5.5 Gbps (or the improved 7Gbs) leads me to suspect
> that gro is still not effective in your test on the vxlan interface
> with the 82588ES nic - Because, when vxlan gro became effective with
> the patch I suggested earlier, I could see throughput of ~8.5 Gbps on
> that nic.

For the 5.X gbit/s test, where I am not getting GRO, I am seeing 1398 
byte data packets when I trace vxlan0.

For the other direction, at 7ish Gbit/s I am seeing 64XXX byte packets 
on vxlan0, with the occasional 25XXX byte packet.  If I disable gro on 
that receiving vxlan0 interface, the throughput is more like 4.X Gbit/s

happy benchmarking,

rick
