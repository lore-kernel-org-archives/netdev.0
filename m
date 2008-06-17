From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: packetloss, on e1000e worse than r8169?
Date: Tue, 17 Jun 2008 09:46:17 +0300
Message-ID: <200806170946.17351.denys@visp.net.lb>
References: <20080616193501.M64730@visp.net.lb> <20080616220841.M50112@visp.net.lb> <36D9DB17C6DE9E40B059440DB8D95F52056AC4C2@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Eric Dumazet" <dada1@cosmosbay.com>, netdev@vger.kernel.org
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:52727 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751942AbYFQGqS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 02:46:18 -0400
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F52056AC4C2@orsmsx418.amr.corp.intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 17 June 2008 02:24, Brandeburg, Jesse wrote:
First, i catch when tx_deferred_ok increasing, rx_missed_errors also increasing.  For example deffered +1 , missed_errors +10.
A bit strange.


> Try turning off Flow Control using ethtool -A ethX rx off tx off autoneg
> off
Well, seems it is a keypoint on new motherboard, but i have to see at peak time still (about 10-14 hours to go).

So the question is, or flow control is broken here, or it is unknown when i must use flow-control and when - not.

Once i had packetloss on e1000 gigabit link, without it. 
Now it is packetloss - when i start to use it.

-- 
------
Technical Manager
Virtual ISP S.A.L.
Lebanon
