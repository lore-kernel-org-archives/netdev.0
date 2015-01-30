From: Arvid Brodin <arvid.brodin@alten.se>
Subject: Re: [PATCH net 0/2] netns: audit netdevice creation with IFLA_NET_NS_[PID|FD]
Date: Fri, 30 Jan 2015 21:00:47 +0100
Message-ID: <54CBE2EF.7050003@alten.se>
References: <1422307694-10079-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <dmitry.tarnyagin@lockless.no>,
	<alex.aring@gmail.com>, <linux-wpan@vger.kernel.org>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spam1.webland.se ([91.207.112.90]:56923 "EHLO spam1.webland.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753978AbbA3UFc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jan 2015 15:05:32 -0500
In-Reply-To: <1422307694-10079-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015-01-26 22:28, Nicolas Dichtel wrote:
*snip*
> - HSR subsystem uses src_net to parse IFLA_HSR_SLAVE[1|2], but the ne=
tdevice has
>   the flag NETIF_F_NETNS_LOCAL, so the question is: does this netdevi=
ce really
>   supports x-netns? If not, the newlink handler should use the dest_n=
et instead
>   of src_net, I can provide the patch.
*snip*

As the author of the HSR driver, I'd like to answer this question, but =
unfortunately=20
I don't know what x-netns is. Neither Google nor Documentation/ has bee=
n particularly
helpful.

Care to elaborate? (Maybe this is a moot point now that the patch has b=
een accepted,
but I'd still like to understand, if you have the time to explain.)

(Pretty much all I know about network namespaces is from this article:=20
http://lwn.net/Articles/580893/.)


--=20
Arvid Brodin | Consultant (Linux)
ALTEN | Knarrarn=C3=A4sgatan 7 | SE-164 40 Kista | Sweden
arvid.brodin@alten.se | www.alten.se/en/
