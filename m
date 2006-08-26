From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH -rt DO NOT APPLY] Fix for tg3 networking lockup
Date: Fri, 25 Aug 2006 17:01:48 -0700
Message-ID: <1156550508.5021.16.camel@rh4>
References: <20060805202603.GA9740@thunk.org>
 <1551EAE59135BE47B544934E30FC4FC093FA21@NT-IRVA-0751.brcm.ad.broadcom.com>
 <loom.20060825T235849-675@post.gmane.org>
 <1156546533.5021.10.camel@rh4>
 <aaccfcb60608251648l138ae3bdre9a41aef3d541d7d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:53519 "EHLO
	MMS3.broadcom.com") by vger.kernel.org with ESMTP id S932336AbWHZACl
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Aug 2006 20:02:41 -0400
To: "Marc Bevand" <m.bevand@gmail.com>
In-Reply-To: <aaccfcb60608251648l138ae3bdre9a41aef3d541d7d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-08-25 at 16:48 -0700, Marc Bevand wrote:

> 
> But I was able to turn TSO on via ethtool -K. This is exactly the behavior I
> would like to see in tg3. So are you saying the patch I applied actually
> breaks ASF ?
> 
Yes, the TSO firmware code that tg3 downloads to the chip using your
patch will overwrite the ASF code.  The ASF code will get reloaded again
at the next chip reset once your patch is reverted.

