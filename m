From: Beschorner Daniel <Daniel.Beschorner@facton.com>
Subject: Re: skge driver oops
Date: Mon, 29 May 2006 19:54:01 +0200
Message-ID: <BB1F4EFD574E9F409035BDA71C9612500241B7@exchange.i-bn>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "'Krzysztof Oledzki'" <olel@ans.pl>, netdev@vger.kernel.org,
	"'david@mantara.com'" <david@mantara.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from loewe.unit-netz.de ([212.202.148.42]:21141 "EHLO
	loewe.unit-netz.de") by vger.kernel.org with ESMTP id S1750764AbWE2RyG
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 May 2006 13:54:06 -0400
To: "'Stephen Hemminger'" <shemminger@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen,

the patch doesn't help.
As soon as the card is receiving lots of data, the box crashes after some
seconds.
Testing these patches is very tricky for me, as it is a production system at
a remote location crashing on every test.

It's a D-Link card, ID 4C00 (530T), SysKonnect's driver is working fine.

Daniel

-----
Stephen Hemminger [mailto:shemminger@osdl.org] 

> Please give this a try, it rearranges the transmit buffer management,
> and may avoid issues with partial completions causing SKB reuse.
