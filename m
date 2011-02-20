From: Micha Nelissen <micha@neli.hopto.org>
Subject: Re: Question about tg3 and bnx2 driver suppliers
Date: Sun, 20 Feb 2011 19:19:25 +0100
Message-ID: <4D615B2D.5080804@neli.hopto.org>
References: <3BA51C2C-B28F-4FED-BF5D-B9BF46EAF3F7@highwire.stanford.edu> <1297952255.2604.115.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Durket <durket@highwire.stanford.edu>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from edu-smtp-02.edutel.nl ([88.159.1.176]:55761 "EHLO
	edu-smtp-02.edutel.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754607Ab1BTS0k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Feb 2011 13:26:40 -0500
In-Reply-To: <1297952255.2604.115.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> One possible cause of packet drops is when softirqs are disabled for too
> long periods, even if NIC has a big RX ring (check ethtool -g eth0)

Why aren't the softirqs converted to workqueues? Wouldn't that cut 
dependencies to other softirq users and improve latency?

Probably a stupid question, thanks.

Micha
