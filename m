From: Pontus Fuchs <pontus.fuchs@gmail.com>
Subject: Re: [cfg80211 / iwlwifi] setting wireless regulatory domain doesn't
 work.
Date: Wed, 18 Dec 2013 08:50:11 +0100
Message-ID: <52B153B3.4070903@gmail.com>
References: <1342235583.20131211182804@eikelenboom.it> <CAB=NE6UfumA2xez1DvtDSBDZ72WF_tOozFo_8LRnMryYiSqD-A@mail.gmail.com> <871324710.20131211191104@eikelenboom.it> <CAB=NE6XRnE0j9NMW0K1vKzEO9v70arSH4YXZjudqa0ZxiLB4AA@mail.gmail.com> <1937118387.20131216122200@eikelenboom.it> <52AEE60B.6030509@broadcom.com> <19210260274.20131216135644@eikelenboom.it> <CAGRGNgXHemM2FfnXgW5RbzhFT+9SfUfVkjdysK3+=_u3hWSacw@mail.gmail.com> <1534126119.20131217104548@eikelenboom.it> <387552477.20131217213319@eikelenboom.it> <20131217212709.GB5624@decadent.org.uk> <1254825772.20131217224914@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Julian Calaby <julian.calaby@gmail.com>,
	Arend van Spriel <arend@broadcom.com>,
	"Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"Berg, Johannes" <johannes.berg@intel.com>,
	"Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"ilw@linux.intel.com" <ilw@linux.intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Avinash Patil <avinashapatil@gmail.com>
To: Sander Eikelenboom <linux@eikelenboom.it>,
	Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:38394 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750961Ab3LRHuS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 02:50:18 -0500
In-Reply-To: <1254825772.20131217224914@eikelenboom.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013-12-17 22:49, Sander Eikelenboom wrote:
>
> Indeed, I looked for a crda hook for initramfs-tools but didn't find it, so skipped that idea
> for the moment.
>
> So if i combine the two .. it's essentially just a very bad idea to compile the wireless stuff in.
> It needs a access to a userland program at module load time, or it will block forever.

The canonical trick to have cfg80211 built in is to execute crda 
manually in your boot scripts. This will satisfy the initial request and 
resolve the block.

Cheers,

Pontus
