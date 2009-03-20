From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 3/3] e1000e: allow tx of pre-formatted vlan
 tagged packets
Date: Fri, 20 Mar 2009 01:31:41 -0700 (PDT)
Message-ID: <20090320.013141.243957487.davem@davemloft.net>
References: <20090319111226.11601.40603.stgit@lost.foo-projects.org>
	<20090319111308.11601.93121.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, ajones@riverbed.com,
	shemminger@vyatta.com, alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55669
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754993AbZCTIby (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 04:31:54 -0400
In-Reply-To: <20090319111308.11601.93121.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 19 Mar 2009 04:13:08 -0700

> From: Arthur Jones <ajones@riverbed.com>
> 
> As with igb, when the e1000e driver is fed 802.1q
> packets with hardware checksum on, it chokes with an
> error of the form:
> 
> checksum_partial proto=81!
> 
> As the logic there was not smart enough to look into
> the vlan header to pick out the encapsulated protocol.
> 
> There are times when we'd like to send these packets
> out without having to configure a vlan on the interface.
> Here we check for the vlan tag and allow the packet to
> go out wiht the correct hardware checksum.
> 
> Thanks to Kand Ly <kand@riverbed.com> for discovering the
> issue and the coming up with a solution.  This patch is
> based upon his work.
> 
> Fixups from Stephen Hemminger <shemminger@vyatta.com> and
> Alexander Duyck <alexander.h.duyck@intel.com>
> 
> Signed-off-by: Arthur Jones <ajones@riverbed.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
