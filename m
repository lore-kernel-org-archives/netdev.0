From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Bridging behavior apparently changed around the Fedora 14 time
Date: Mon, 11 Jul 2011 13:49:38 -0700
Message-ID: <20110711134938.5178797c@nehalam.ftrdhcpuser.net>
References: <925A849792280C4E80C5461017A4B8A2A040F0@mail733.InfraSupportEtc.com>
	<20110711130729.607d461e@nehalam.ftrdhcpuser.net>
	<925A849792280C4E80C5461017A4B8A2A040F3@mail733.InfraSupportEtc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	"Lynn Hanson" <LynnHanson@eaganhills.org>,
	"Joe Whalen" <JoeWhalen@eaganhills.org>
To: "Greg Scott" <GregScott@Infrasupport.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45097 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750901Ab1GKUtl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jul 2011 16:49:41 -0400
In-Reply-To: <925A849792280C4E80C5461017A4B8A2A040F3@mail733.InfraSupportEtc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 11 Jul 2011 15:41:35 -0500
"Greg Scott" <GregScott@Infrasupport.com> wrote:

> The NICs are 3Com 3C905B's.  The iptables config is complex - I'll paste
> in the relevant pieces.  Note that it all works as expected when I put
> the br0 device into promiscuous mode.  I included all the layer 2 MAC
> address info in the original email.  
> 
> > Do you have reverse path filtering enabled/disabled?  
> 
> rp_filter doesn't seem to effect the behavior one way or the other.
> I've tried with rp_filter set to both 0 and 1 on eth0, eth1, and br0
> with no change in behavior.  

What about console dmesg output.
Because you can fix by putting in promiscuous mode, I suspect the
problem is outside of the bridge itself, could be the drivers.
The bridge itself puts the device into promiscuous mode already.

Lastly, the Fedora and upstream kernels are not exactly the same.
Please retest with a standard upstream kernel (like 2.6.39.2).
