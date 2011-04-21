From: Marco Chiappero <marco@absence.it>
Subject: Re: rfkill-input to be removed
Date: Thu, 21 Apr 2011 18:45:32 +0200
Message-ID: <4DB05F2C.1080208@absence.it>
References: <4DAFEAA7.5090003@absence.it> <1303402951.3597.27.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aa012-1msr.fastwebnet.it ([62.101.93.132]:42413 "EHLO
	aa012-1msr.fastwebnet.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753000Ab1DUQre (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2011 12:47:34 -0400
In-Reply-To: <1303402951.3597.27.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Il 21/04/2011 18:22, Johannes Berg ha scritto:
> Yeah we noticed this before with some other drivers. The persistent
> stuff seems to only be suitable for a small number of semantics.

Sorry, what do you mean exactly? The persistent stuff seems to work well 
with those notebooks.

> Frankly, I don't think we're ready for this yet, most distros don't yet
> ship the rfkill daemon.

Ok, in the meantime I'm going to avoid the SW_RFKILL_ALL switch event 
forwarding, unless the master_switch_mode=1 is going to be changed to 
honor the stored power state on drivers loading as well, not only when 
moving the "kill all" switch (it seems that on boot every device is 
always turned on, which is very annoying).


