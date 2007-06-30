From: Matthew Garrett <mjg59@srcf.ucam.org>
Subject: Re: [PATCH] b44: power down PHY when interface down
Date: Sat, 30 Jun 2007 16:19:23 +0100
Message-ID: <20070630151923.GA22983@srcf.ucam.org>
References: <4354d3270706300447ladcda4by987b1f87963112f9@mail.gmail.com> <20070630120541.GA21339@srcf.ucam.org> <46866C6B.9010801@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: =?iso-8859-1?B?VPZy9ms=?= Edvin <edwintorok@gmail.com>,
	netdev@vger.kernel.org, power@bughost.org, zambrano@broadcom.com,
	linux-kernel@vger.kernel.org
To: Arjan van de Ven <arjan@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cavan.codon.org.uk ([217.147.92.49]:48239 "EHLO
	vavatch.codon.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753209AbXF3PTs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jun 2007 11:19:48 -0400
Content-Disposition: inline
In-Reply-To: <46866C6B.9010801@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 30, 2007 at 07:44:59AM -0700, Arjan van de Ven wrote:
> Matthew Garrett wrote:
> >Do you still get link beat detection when the phy is powered down?
> >
> does that matter?
> If the interface is down, nic drivers aren't expected to detect 
> link... if userspace wants to find link status it should have the 
> interface up.

If that's the policy, why do we leave this up to individual drivers? 
Right now most of them let you make the query regardless of interface 
state.

I'd agree that there's a need for a state where we power down as much as 
possible (even at the cost of functionality), but where possible it 
would also be nice to offer a state where the mac is powered down and 
the phy left up. If the existing semantics are confused then it would be 
nice to fix them, too.
-- 
Matthew Garrett | mjg59@srcf.ucam.org
