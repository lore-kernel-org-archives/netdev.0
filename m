From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] Disable TSO for non standard qdiscs
Date: Thu, 31 Jan 2008 10:26:19 -0800
Message-ID: <47A212CB.1060403@hp.com>
References: <20080131124632.GA25299@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:10590 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763035AbYAaS0W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 13:26:22 -0500
In-Reply-To: <20080131124632.GA25299@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen wrote:
> TSO interacts badly with many queueing disciplines because they rely on 
> reordering packets from different streams and the large TSO packets can 
> make this difficult. This patch disables TSO for sockets that send over 
> devices with non standard queueing disciplines. That's anything but noop 
> or pfifo_fast and pfifo right now.

Does this also imply that JumboFrames interacts badly with these qdiscs? 
  Or IPoIB with its 65000ish byte MTU?

rick jones
