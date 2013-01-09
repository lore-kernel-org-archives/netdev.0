From: "pupilla@libero.it" <pupilla@libero.it>
Subject: R: Re: mtu issue with ipsec tunnel and netfilter snat
Date: Wed, 9 Jan 2013 10:55:43 +0100 (CET)
Message-ID: <23614781.2953131357725343800.JavaMail.defaultUser@defaultHost>
Reply-To: "pupilla@libero.it" <pupilla@libero.it>
Mime-Version: 1.0
Content-Type: text/plain;charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <jengelh@inai.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outrelay02.libero.it ([212.52.84.102]:34570 "EHLO
	outrelay02.libero.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757480Ab3AIJzp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2013 04:55:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jengelh@inai.de wrote:
>On Wednesday 2013-01-09 10:01, pupilla@libero.it wrote:
>
>>As you can see there are incoming 1500 bytes packets (these are the
>>decrypted ipsec packets) with DF bit set. These packets are never
>>delivered to the final client 10.81.128.176 (the destination address
>>is 172.16.128.1 which is the ip used for SNATing the original ip
>>10.81.128.176).
>>
>>IMHO this is a mtu issue: 1500 bytes packets cannot be routed inside
>>the ipsec tunnel.
>>
>>But why linux_gw_snat is not sending icmp need to frag packets to
>>10.148.12.23?
>
>Perhaps because ICMP was blocked erroneously?

No, I have opened the firewall
rules with something like:

iptables -I OUTPUT --proto icmp -j ACCEPT
iptables -I INPUT --proto icmp -j ACCEPT
