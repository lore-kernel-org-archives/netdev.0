From: "Denys" <denys@visp.net.lb>
Subject: Re: iproute2-2.6.20-070313 bug ?
Date: Thu, 22 Mar 2007 15:47:54 +0200
Message-ID: <20070322134552.M83364@visp.net.lb>
References: <20070321175951.M73913@visp.net.lb> <46026717.9060909@trash.net> <20070322124533.M79867@visp.net.lb> <46027FF2.6020001@trash.net> <20070322131245.M85528@visp.net.lb> <46028335.3030402@trash.net> <20070322132637.M88445@visp.net.lb> <4602880F.1010403@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:54445 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932386AbXCVNsL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2007 09:48:11 -0400
In-Reply-To: <4602880F.1010403@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi again

On Thu, 22 Mar 2007 14:43:43 +0100, Patrick McHardy wrote
> Denys wrote:
> >>>Another thing, it is working well 
> >>>with old tc. Just really if i have plenty of RAM's and i want 32second 
> >>>buffer, why i cannot have that, and if i see it is really possible 
before?
> >>
> >>I know it worked before. But I can't think of a reason why anyone
> >>would want a buffer that large. Why do you want to queue packets
> >>for up to 64 seconds?
> > 
> > Seems i misunderstand how it works. If i am not wrong, till buffer 
available, 
> > bandwidth will be given on "peakrate" speed, and when buffer is empty - 
on 
> > "rate" speed. I am wrong?
> 
> No, I got confused, sorry about that. Your configuration allows 
> bursts up to 64 seconds long. I guess there's nothing wrong with that.
> 
> I already asked Stephen to revert that patch, it was not meant to
> be included yet, unfortunately it made it into the release. Even
> more unfortunate is that it looks like we need larger types in the
> ABI to properly support nano-second resolution.

Thanks sir for your great help and great software and sorry that i took time, 
by not enough good explanation. 

--
Virtual ISP S.A.L.

