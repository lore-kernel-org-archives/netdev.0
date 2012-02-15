From: Jean Delvare <jdelvare@suse.de>
Subject: Re: bonding with 3c59x driver
Date: Wed, 15 Feb 2012 10:53:14 +0100
Message-ID: <201202151053.14384.jdelvare@suse.de>
References: <201202132253.16496.jdelvare@suse.de> <201202142027.13147.jdelvare@suse.de> <4F3ACCEE.6070701@genband.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Steffen Klassert <klassert@mathematik.tu-chemnitz.de>,
	Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org
To: Chris Friesen <chris.friesen@genband.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:41337 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751647Ab2BOJxR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Feb 2012 04:53:17 -0500
In-Reply-To: <4F3ACCEE.6070701@genband.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 14 February 2012 10:06:54 pm Chris Friesen wrote:
> On 02/14/2012 01:27 PM, Jean Delvare wrote:
> > Without the patch above, doing bonding on top of 3c59x is simply
> > not possible, at least not in active-backup mode. For other modes
> > it depends if you are only interested in load balancing or also on
> > redundancy.
> 
> Could you just use arp monitoring instead of mii?

If it was just for me, I could, and probably would. But when I am trying 
to reproduce a customer bug, I have to use exactly the same options the 
customer is using.

-- 
Jean Delvare
Suse L3
