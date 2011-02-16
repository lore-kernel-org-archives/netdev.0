From: David Miller <davem@davemloft.net>
Subject: Re: [stable] [PATCH net-2.6/stable] tg3: Restrict phy ioctl access
Date: Wed, 16 Feb 2011 15:11:03 -0800 (PST)
Message-ID: <20110216.151103.189711682.davem@davemloft.net>
References: <1297810270-4690-1-git-send-email-mcarlson@broadcom.com>
	<20110216223935.GF22056@kroah.com>
	<20110216230613.GA11053@mcarlson.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greg@kroah.com, netdev@vger.kernel.org, stable@kernel.org
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45421
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750981Ab1BPXK1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Feb 2011 18:10:27 -0500
In-Reply-To: <20110216230613.GA11053@mcarlson.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Wed, 16 Feb 2011 15:06:13 -0800

> On Wed, Feb 16, 2011 at 02:39:35PM -0800, Greg KH wrote:
>> On Tue, Feb 15, 2011 at 02:51:10PM -0800, Matt Carlson wrote:
>> > If management firmware is present and the device is down, the firmware
>> > will assume control of the phy.  If a phy access were allowed from the
>> > host, it will collide with firmware phy accesses, resulting in
>> > unpredictable behavior.  This patch fixes the problem by disallowing phy
>> > accesses during the problematic condition.
>> > 
>> > Upstream commit ID f746a3136a61ae535c5d0b49a9418fa21edc61b5
>> 
>> There is no such upstream git commit id in Linus's tree.  What am I
>> doing wrong here?
> 
> The commit is in Dave Miller's net-next-2.6 tree.
> 

If it wasn't appropriate for net-2.6, it absolutely it not appropriate
for -stable.
