From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Bonding ALB sends bogus packets
Date: Thu, 30 Jul 2009 16:48:28 -0700
Message-ID: <4A72314C.9080007@hp.com>
References: <20090730130656.680e9152@nehalam>	<22132.1248985699@death.nxdomain.ibm.com>	<20090730133545.77e5a76a@nehalam> <20090731090658.db36b555.lk-netdev@lk-netdev.nosense.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Ben Greear <greearb@candelatech.com>,
	bonding-devel@lists.sf.net, netdev@vger.kernel.org
To: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:30098 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751477AbZG3Xsa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2009 19:48:30 -0400
In-Reply-To: <20090731090658.db36b555.lk-netdev@lk-netdev.nosense.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mark Smith wrote:
> 
> ETH_P_LOOP should probably have been avoided, as "LOOP" or "loopback"
> is commonly used to refer to the Ethernet Configuration Testing
> Protocol (google search for "Ethernet Loop protocol"). 

I wonder how that relates to linkloop:

http://sourceforge.net/projects/linkloop/

http://fr2.rpmfind.net/linux/RPM/opensuse/factory/x86_64/usr_share_doc_packages_linkloop_Tree.html

> 
> I'd suggest not using any form of ARP for this purpose. It'd place an
> IPv4 requirement on the bonded interface, and various "empty" ARP
> frames have meaning e.g. duplicate address detection. 802.2 test frames
> or the original Ethernet V2.0 Configuration Testing Protocol have been
> used for this bridge table address refresh purpose in the past.

I can never remember if linkloop uses XID or Test frames :(

rick jones
