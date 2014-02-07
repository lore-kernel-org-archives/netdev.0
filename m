From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: VLAN ID 0 with priority tagging
Date: Fri, 07 Feb 2014 10:08:06 +0900
Message-ID: <52F431F6.9010605@lab.ntt.co.jp>
References: <52E05901.6050601@us.ibm.com> <52F4207A.6020408@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Sridhar Samudrala <samudrala.sridhar@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:42124 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751925AbaBGBIM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 20:08:12 -0500
In-Reply-To: <52F4207A.6020408@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(2014/02/07 8:53), Sridhar Samudrala wrote:
> On 1/22/2014 3:49 PM, Sridhar Samudrala wrote:
>> I am trying to send a packet with VLAN ID 0 and non-zero priority.
>>
>> The VLAN interfaces are created on 2 hosts using
>>     ip link add link eth1 eth1.0 type vlan id 0 egress-qos-map 0:2
>>
>> When i try to send a packet using ping/arping, on the sender side tcpdump
>> shows that the VLAN tag is added with ID 0 and priority 2.
>>
>> However, the receiver is receiving the packet with vlan tag stripped.
>>
>> I am seeing the same behavior with multiple NICs and also with a
>> switch in
>> between the 2 hosts or with the 2 hosts connected over loopback cable.
>>
>> It looks as if the driver on the send side is stripping the tag if
>> vlan id is 0.
>> Is this correct behavior or a bug?
>> Any clues on how to  get priority tagging to work with vlan id 0?
>>
> I sent this note a few weeks back, but i haven't seen any response so far.
> 
> Is priority tagging with VLAN ID 0 not supported or is this a bug?
> It looks like the NIC hardware is stripping the VLAN tag if the id is 0
> even when VLAN tag
> is added by the software.

eth1.0 should be able to send frames tagged with vid 0.
Though I don't know whether there are NICs/drivers that strip tag 0, I
can send frames with vid 0 (with e1000e).

Toshiaki Makita
