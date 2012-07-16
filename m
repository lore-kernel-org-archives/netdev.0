From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: resurrecting tcphealth
Date: Mon, 16 Jul 2012 13:46:25 +0200
Message-ID: <1342439185.23494.19.camel@edumazet-glaptop>
References: <e9caf38359467bfa8a1e2ac86f6ef2cc.squirrel@webmail.univie.ac.at>
	 <20120713165544.6767ea8f@nehalam.linuxnetplumber.net>
	 <87741204cd72d363d54dadf9a94bb6fe.squirrel@webmail.univie.ac.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Piotr Sawuk <a9702387@unet.univie.ac.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:34067 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752540Ab2GPLqa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2012 07:46:30 -0400
In-Reply-To: <87741204cd72d363d54dadf9a94bb6fe.squirrel@webmail.univie.ac.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-07-16 at 13:33 +0200, Piotr Sawuk wrote:
> On Sa, 14.07.2012, 01:55, Stephen Hemminger wrote:
> > I am not sure if the is really necessary since the most
> > of the stats are available elsewhere.
> 
> if by "most" you mean address and port then you're right.
> but even the rtt reported by "ss -i" seems to differ from tcphealth.

Thats because tcphealth is wrong, it assumes HZ=1000 ?

tp->srtt unit is jiffies, not ms.

tcphealth is a gross hack.
