From: Patrick McHardy <kaber@trash.net>
Subject: Re: iproute2-2.6.20-070313 bug ?
Date: Thu, 22 Mar 2007 14:23:01 +0100
Message-ID: <46028335.3030402@trash.net>
References: <20070321175951.M73913@visp.net.lb> <46026717.9060909@trash.net> <20070322124533.M79867@visp.net.lb> <46027FF2.6020001@trash.net> <20070322131245.M85528@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@osdl.org>
To: Denys <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35924 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751604AbXCVNXE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2007 09:23:04 -0400
In-Reply-To: <20070322131245.M85528@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please don't remove CCs.

Denys wrote:
> 1024kb (if i am not wrong 1Mbyte) is huge?
> 
> For me it is ok, as soon as i have RAM.


Its not about the memory, its about the resulting queueing delay.
If you buffer packets for 64 seconds the sender will retransmit
them and you end up wasting bandwidth.

> Another thing, it is working well 
> with old tc. Just really if i have plenty of RAM's and i want 32second 
> buffer, why i cannot have that, and if i see it is really possible before?


I know it worked before. But I can't think of a reason why anyone
would want a buffer that large. Why do you want to queue packets
for up to 64 seconds?
