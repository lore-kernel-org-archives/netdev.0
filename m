From: Michael Buesch <mb@bu3sch.de>
Subject: Re: Suspending 802.11 drivers
Date: Thu, 15 Jun 2006 22:42:47 +0200
Message-ID: <200606152242.48125.mb@bu3sch.de>
References: <200606152158.10079.mb@bu3sch.de> <200606152213.01631.florian@alphacore.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:8086
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S932503AbWFOUtx
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jun 2006 16:49:53 -0400
To: Florian Fainelli <florian@alphacore.net>
In-Reply-To: <200606152213.01631.florian@alphacore.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 15 June 2006 22:12, Florian Fainelli wrote:
> Hello Michael,
> 
> I think these are really interesting functions. Currently I scripted a bit to 
> do module unloading/loading on suspend/resume requests plus supplicant 
> context saving and restart.
> 
> Of course, if the driver is able to manage this by itself, it's far better.

Well, if the _suspend() and _resume() semantics are actually implemented
in kernel or userspace is another question. I would say, it should be possible
to defer it to userspace, after the userspace MLME stuff is done.
But that does not really matter here to get my point. My point is:
ieee80211 subsystem should provide functions which save/restore the
whole state of the stack (Well, the state of running connections and
associations ,actually). How these functions are implemented internally
is another matter.
But I would also say that it sounds sane to put these semantics into
userspace, in the long term.

> Any news on the power management specifications ?

No. I think I will start another attempt to measure the power consumption
of the card, soon. Maybe this time I will be able to figure out the
meaning of the PS bits :) I think I forgot to set important bits
last time I checked.

-- 
Greetings Michael.
