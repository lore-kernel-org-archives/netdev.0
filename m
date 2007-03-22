From: Patrick McHardy <kaber@trash.net>
Subject: Re: iproute2-2.6.20-070313 bug ?
Date: Thu, 22 Mar 2007 14:43:43 +0100
Message-ID: <4602880F.1010403@trash.net>
References: <20070321175951.M73913@visp.net.lb> <46026717.9060909@trash.net> <20070322124533.M79867@visp.net.lb> <46027FF2.6020001@trash.net> <20070322131245.M85528@visp.net.lb> <46028335.3030402@trash.net> <20070322132637.M88445@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Denys <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36355 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932201AbXCVNnq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2007 09:43:46 -0400
In-Reply-To: <20070322132637.M88445@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Denys wrote:
>>>Another thing, it is working well 
>>>with old tc. Just really if i have plenty of RAM's and i want 32second 
>>>buffer, why i cannot have that, and if i see it is really possible before?
>>
>>I know it worked before. But I can't think of a reason why anyone
>>would want a buffer that large. Why do you want to queue packets
>>for up to 64 seconds?
> 
> Seems i misunderstand how it works. If i am not wrong, till buffer available, 
> bandwidth will be given on "peakrate" speed, and when buffer is empty - on 
> "rate" speed. I am wrong?


No, I got confused, sorry about that. Your configuration allows bursts
up to 64 seconds long. I guess there's nothing wrong with that.

I already asked Stephen to revert that patch, it was not meant to
be included yet, unfortunately it made it into the release. Even
more unfortunate is that it looks like we need larger types in the
ABI to properly support nano-second resolution.

