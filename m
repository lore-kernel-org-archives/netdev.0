From: Arend van Spriel <arend@broadcom.com>
Subject: Re: [net-next v2 3/3] cfg80211: add MPLS and 802.21 classification
Date: Tue, 18 Feb 2014 18:30:30 +0100
Message-ID: <530398B6.2060806@broadcom.com>
References: <1392656174-14791-4-git-send-email-sw@simonwunderlich.de>	<5302474B.6090609@broadcom.com>	<D53252F45158EF44B1DF124FDC9AF2A35AD9E12C@FEYNMAN.fokus.fraunhofer.de> <20140217.140653.1309552047403078220.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <sw@simonwunderlich.de>, <netdev@vger.kernel.org>,
	<linux-wireless@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	<mathias.kretschmer@fokus.fraunhofer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:38345 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751239AbaBRRbD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 12:31:03 -0500
In-Reply-To: <20140217.140653.1309552047403078220.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/17/2014 08:06 PM, David Miller wrote:
> From: "Kretschmer, Mathias" <mathias.kretschmer@fokus.fraunhofer.de>
> Date: Mon, 17 Feb 2014 17:34:34 +0000
> 
>> Thought so, as well. But it seems that skb->protocol is not properly
>> set when the packet originates from a packet socket.  And in our
>> case we cannot set it to a fixed etherType in the bind() call since
>> we use three different etherTypes on the same socket.
> 
> So many things break if the skb->protocol isn't set correctly that I
> would consider such SKBs mal-formed.

That was my take as well, but how does the kernel code consider this?

> You can specify the protocol number in the msghdr passed into the
> send.
> 

Regards,
Arend
