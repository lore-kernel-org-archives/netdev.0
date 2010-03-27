From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] ixgbe: Do not run all Diagnostic offline tests
 when VFs are active
Date: Sat, 27 Mar 2010 08:33:55 -0700 (PDT)
Message-ID: <20100327.083355.112601140.davem@davemloft.net>
References: <20100326030647.10085.16720.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, gregory.v.rose@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53704
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752929Ab0C0Pdb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Mar 2010 11:33:31 -0400
In-Reply-To: <20100326030647.10085.16720.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 25 Mar 2010 20:06:48 -0700

> From: Greg Rose <gregory.v.rose@intel.com>
> 
> When running the offline diagnostic tests check to see if any VFs are
> online.  If so then only run the link test.  This is necessary because
> the VFs running in guest VMs aren't aware of when the PF is taken
> offline for a diagnostic test.  Also put a message to the system log
> telling the system administrator to take the VFs offline manually if
> (s)he wants to run a full diagnostic.  Return 1 on each of the tests
> not run to alert the user of the condition.
> 
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
