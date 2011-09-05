From: Ang Way Chuang <wcang@sfc.wide.ad.jp>
Subject: Re: [PATCH 1/2] bridge: leave carrier on for empty bridge
Date: Tue, 06 Sep 2011 04:02:12 +0900
Message-ID: <4E651CB4.3070707@sfc.wide.ad.jp>
References: <20110902172220.830228928@vyatta.com> <20110902172247.396753508@vyatta.com> <4E614CF7.7030700@gmail.com> <20110902151100.327af0bf@nehalam.ftrdhcpuser.net> <4E6272BC.4020707@gmail.com> <20110903211438.2a43d2f2@nehalam.ftrdhcpuser.net> <4E632A2E.5040805@gmail.com> <20110904093634.685d7c56@nehalam.ftrdhcpuser.net> <4E65046E.1020005@gmail.com> <20110905105735.1b912715@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:50918 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751651Ab1IETCO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Sep 2011 15:02:14 -0400
In-Reply-To: <20110905105735.1b912715@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/09/11 02:57, Stephen Hemminger wrote:
> The root cause of the problem is applications that don't deal with unresolved
> IPv6 addresses. I already had to solve this in our distribution for NTP in a
> not bridge related problem. It is better to fix the applications to understand
> IPv6 address semantics than to try and force bridge to behave in a way that
> is friendly to these applications.
Care to share the patch that you did for NTP? Perhaps, I may apply the same trick and tried it out on dnsmasq and radvd if I have time.
Thanks.
>
> The earlier mail said it is a problem with dnsmasq and radvd. Let's work on understanding
> if they need to be updated before jumping in with hacks to the bridge code.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
