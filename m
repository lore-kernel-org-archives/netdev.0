From: Helmut Grohne <h.grohne@cygnusnetworks.de>
Subject: Re: TUN/TAP: tap driver reports bogus interface speed in ethtool operations
Date: Tue, 23 Jul 2013 18:03:54 +0200
Message-ID: <27AF15CB-BF6D-4C28-B9C1-BF880C482D12@cygnusnetworks.de>
References: <2F174B03-5074-4BA0-B91A-8F2F62C2B082@cygnusnetworks.de> <5192BDD6.6060703@qti.qualcomm.com> <3E916AF0-C587-443D-B653-C968A96C8751@cygnusnetworks.de> <48A2F278-A32C-47C6-AD2D-1FC15EC73B88@cygnusnetworks.de> <51E5BE27.3060207@qti.qualcomm.com> <E4A37B97-95FE-42C3-AD78-119BA406A44A@cygnusnetworks.de> <51EEA5ED.6080404@hp.com> <20130723085611.0c77c314@nehalam.linuxnetplumber.net>
Mime-Version: 1.0 (Mac OS X Mail 6.5 \(1508\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Max Krasnyansky <maxk@qti.qualcomm.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.w359.de ([46.189.116.21]:35284 "EHLO mail2.w359.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932595Ab3GWQD6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 12:03:58 -0400
In-Reply-To: <20130723085611.0c77c314@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23.07.2013, at 17:56, Stephen Hemminger <stephen@networkplumber.org> wrote:
> I have hack patch to allow overwriting speed, info, and statistics that is part
> of how we use TUN as dummy devices. How far do you think makes sense?

That could prove useful for creating test environments for tools, that use ethtool.
If you have a better patch, then go for it. The reason for why I did not include
other settings was that I don't need them. I'm open to other solutions as well, as
long as they either make the speed modifiable or something faster than SPEED_10.

Helmut