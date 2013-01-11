From: "pupilla@libero.it" <pupilla@libero.it>
Subject: R: Re: R: Re: mtu issue with ipsec tunnel and netfilter snat
Date: Fri, 11 Jan 2013 16:34:04 +0100 (CET)
Message-ID: <19220632.617321357918444464.JavaMail.defaultUser@defaultHost>
Reply-To: "pupilla@libero.it" <pupilla@libero.it>
Mime-Version: 1.0
Content-Type: text/plain;charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <jengelh@inai.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outrelay03.libero.it ([212.52.84.103]:46639 "EHLO
	outrelay03.libero.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752022Ab3AKPeH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2013 10:34:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jengelh@inai.de wrote
>On Thursday 2013-01-10 17:46, pupilla@libero.it wrote:
>
>>jengelh@inai.de wrote:
>>>>
>>>>But why linux_gw_snat is not sending icmp need to frag packets to
>>>>10.148.12.23?
>>>
>>>Perhaps because ICMP was blocked erroneously?
>>
>>well, I don't see the icmp packets because tcpdump 'see' only the 
>>incoming ipsec clear packets. Is there a way to see the outgoing clear 
>>ipsec packets with tcpdump?
>
>Not with AF_PACKET sockets (tcpdump uses such), but you could with 
>iptables -j LOG, NFLOG and TRACE they can be made visible. If you need 
>the full packet, you can either patch up LOG to call the kernel hexdump 
>functions, or use NFLOG - I think - to deliver it to any userspace 
>program to do further processing. If all else fails, there is also 
>NFQUEUE with which the packet can also be copied to userspace.
>

Thanks for the reply.
I have saved the esp packets with tcpdump and then
decrypted with wireshark. Indeed, the icmp need to
frag packets are being sent by the linux ipsec
gateway.

Thanks for support.
