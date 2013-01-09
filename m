From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: mtu issue with ipsec tunnel and netfilter snat
Date: Wed, 9 Jan 2013 10:51:40 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1301091050370.20022@nerf07.vanv.qr>
References: <23599275.2918881357722114614.JavaMail.defaultUser@defaultHost>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: "pupilla@libero.it" <pupilla@libero.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ares07.inai.de ([5.9.24.206]:49119 "EHLO ares07.inai.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757422Ab3AIJvm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jan 2013 04:51:42 -0500
In-Reply-To: <23599275.2918881357722114614.JavaMail.defaultUser@defaultHost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wednesday 2013-01-09 10:01, pupilla@libero.it wrote:

>As you can see there are incoming 1500 bytes packets (these are the
>decrypted ipsec packets) with DF bit set. These packets are never
>delivered to the final client 10.81.128.176 (the destination address
>is 172.16.128.1 which is the ip used for SNATing the original ip
>10.81.128.176).
>
>IMHO this is a mtu issue: 1500 bytes packets cannot be routed inside
>the ipsec tunnel.
>
>But why linux_gw_snat is not sending icmp need to frag packets to
>10.148.12.23?

Perhaps because ICMP was blocked erroneously?
