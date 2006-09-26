From: Michael Stone <mstone@mathom.us>
Subject: Re: [PATCH] skge: fiber support
Date: Tue, 26 Sep 2006 11:45:01 -0400
Message-ID: <20060926154459.GA6030@mathom.us>
References: <20060815131852.GP2900@mathom.us>
 <20060921153939.739947ab@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms048pub.verizon.net ([206.46.252.48]:19869 "EHLO
	vms048pub.verizon.net") by vger.kernel.org with ESMTP
	id S932140AbWIZPxX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Sep 2006 11:53:23 -0400
Received: from osgiliath.mathom.us ([72.66.19.85])
 by vms048.mailsrvcs.net (Sun Java System Messaging Server 6.2-4.02 (built Sep
 9 2005)) with ESMTPA id <0J6700L8XIF6P66B@vms048.mailsrvcs.net> for
 netdev@vger.kernel.org; Tue, 26 Sep 2006 10:45:07 -0500 (CDT)
In-reply-to: <20060921153939.739947ab@dxpl.pdx.osdl.net>
To: Stephen Hemminger <shemminger@osdl.org>
Content-disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 21, 2006 at 03:39:39PM -0700, Stephen Hemminger wrote:
>Add support for older fiber versions of the SysKonnect board. These chipsets
>use an internal PHY so they require special handling. The older sk98lin
>driver already supported these

The patch seems to work with a single port card SX card. I'll test with 
LX & dual port shortly. One thing that I haven't got working is forcing 
the card up if autonegotiation isn't possible. (It used to be a module 
parameter like AutoNeg=Off for sk98lin; I've tried (unsuccessfully) to 
use ethtool to turn off autoneg, but I'll try harder.)

Mike Stone
