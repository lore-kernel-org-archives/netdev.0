From: David Miller <davem@davemloft.net>
Subject: Re: [patch]reset_resume for cdc-ether
Date: Thu, 03 Dec 2009 12:31:50 -0800 (PST)
Message-ID: <20091203.123150.182603807.davem@davemloft.net>
References: <200912031056.17103.oliver@neukum.org>
	<20091203.021456.40580217.davem@davemloft.net>
	<200912031402.48289.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torgny.johansson@ericsson.com, david-b@pacbell.net,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: oliver@neukum.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51660
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753866AbZLCUbn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 15:31:43 -0500
In-Reply-To: <200912031402.48289.oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Neukum <oliver@neukum.org>
Date: Thu, 3 Dec 2009 14:02:48 +0100

> Am Donnerstag, 3. Dezember 2009 11:14:56 schrieb David Miller:
> 
>> It doesn't apply to my tree still:
> 
> And this is autosuspend.

Oliver, when you send two patches to the same files you
have to make it so that when the first one is applied
the second one applies cleanly on top.  That's not what
happens here:

davem@sunset:~/src/GIT/net-next-2.6$ git am --signoff bundle-732.mbox
Applying: cdc-ether: Implement reset_resume()
Applying: usbnet & cdc-ether: autosuspend for online devices
error: patch failed: drivers/net/usb/cdc_ether.c:411
error: drivers/net/usb/cdc_ether.c: patch does not apply
Patch failed at 0002 usbnet & cdc-ether: autosuspend for online devices
When you have resolved this problem run "git am --resolved".
If you would prefer to skip this patch, instead run "git am --skip".
To restore the original branch and stop patching run "git am --abort".

Also, please compose your patch emails correctly, I always have
to edit them.

The commit message header line should be your subject (with
something like "[PATCH 01/02] " or similar prefixed).

The body of your email should be the commit message contents
and then the patch.

If you want to make some extra comments that are not meant to
go into the commit message, put a line with just "---" after
the commit message (and before the patch), and then add what
you want to say.

Finally, please capitalize and properly spell words when appropriate.
F.e. "imlement" should be "Implement" in the commit header line of the
reset_resume() commit.
