From: "Denys" <denys@visp.net.lb>
Subject: Re: iproute2-2.6.20-070313 bug ?
Date: Thu, 22 Mar 2007 15:35:38 +0200
Message-ID: <20070322133538.M93466@visp.net.lb>
References: <20070321175951.M73913@visp.net.lb> <46026717.9060909@trash.net> <20070322124533.M79867@visp.net.lb> <46027FF2.6020001@trash.net> <20070322131245.M85528@visp.net.lb> <46028335.3030402@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:37415 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932190AbXCVNfy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2007 09:35:54 -0400
In-Reply-To: <46028335.3030402@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 22 Mar 2007 14:23:01 +0100, Patrick McHardy wrote
> Please don't remove CCs.
> 
> Denys wrote:
> > 1024kb (if i am not wrong 1Mbyte) is huge?
> > 
> > For me it is ok, as soon as i have RAM.
> 
> Its not about the memory, its about the resulting queueing delay.
> If you buffer packets for 64 seconds the sender will retransmit
> them and you end up wasting bandwidth.
> 
> > Another thing, it is working well 
> > with old tc. Just really if i have plenty of RAM's and i want 32second 
> > buffer, why i cannot have that, and if i see it is really possible before?
> 
> I know it worked before. But I can't think of a reason why anyone
> would want a buffer that large. Why do you want to queue packets
> for up to 64 seconds?
Seems i misunderstand how it works. If i am not wrong, till buffer available, 
bandwidth will be given on "peakrate" speed, and when buffer is empty - on 
"rate" speed. I am wrong?
At least it was working like this before.

--
Virtual ISP S.A.L.

