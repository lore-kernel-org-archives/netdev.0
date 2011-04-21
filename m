From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: rfkill-input to be removed
Date: Thu, 21 Apr 2011 18:22:31 +0200
Message-ID: <1303402951.3597.27.camel@jlt3.sipsolutions.net>
References: <4DAFEAA7.5090003@absence.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Marco Chiappero <marco@absence.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:41073 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753462Ab1DUQWc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2011 12:22:32 -0400
In-Reply-To: <4DAFEAA7.5090003@absence.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-04-21 at 10:28 +0200, Marco Chiappero wrote:
> While working on the the sony-laptop driver, adding support for 
> persistent rfkill state storing and adding the SW_RFKILL_ALL switch 
> event forwarding to the input core to notify userspace, I realized that 
> rfkill-input interferes with correct behavior of the driver, vanishing 
> the hardware device state storing. 

Yeah we noticed this before with some other drivers. The persistent
stuff seems to only be suitable for a small number of semantics.

> Then, looking at 
> Documentation/feature-removal-schedule.txt I realized that rfkill-input 
> was scheduled to be removed in 2.6.33, but it's still there in 2.6.39. 
> Please remove that code as soon as possible, rfkill input events should 
> be handled by user space tools.

Frankly, I don't think we're ready for this yet, most distros don't yet
ship the rfkill daemon.

johannes

