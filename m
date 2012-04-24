From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: My e1000e GBE card is eating all port 623 pks
Date: Tue, 24 Apr 2012 14:51:28 -0700
Message-ID: <20120424145128.000070a8@unknown>
References: <OF8F83D7F0.387F6CCE-ONC12579E7.0049B885-C12579E7.004A4356@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:62902 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757722Ab2DXVva (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Apr 2012 17:51:30 -0400
In-Reply-To: <OF8F83D7F0.387F6CCE-ONC12579E7.0049B885-C12579E7.004A4356@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 21 Apr 2012 15:31:09 +0200
Joakim Tjernlund <joakim.tjernlund@transmode.se> wrote:
 
> Looks like port 623 is some mgmt protocol and our e1000e boards are eating these
> pkgs and this trips NIS, finger and yptest hangs for a long time before timing out and
> moving on.
> 
> Is there a way to tell the network stack not to eat port 623 pkgs or
> have NIS not to use port 623?

I think you might be looking for something like portreserve 
(see man portreserve)

Jesse
