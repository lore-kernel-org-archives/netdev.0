From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Tue, 31 Mar 2009 22:18:43 +0200
Message-ID: <87ab71monw.fsf@basil.nowhere.org>
References: <20090331184057.28333.77287.stgit@dev.haskins.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, anthony@codemonkey.ws, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Gregory Haskins <ghaskins@novell.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757421AbZCaUTT@vger.kernel.org>
In-Reply-To: <20090331184057.28333.77287.stgit@dev.haskins.net> (Gregory Haskins's message of "Tue, 31 Mar 2009 14:42:47 -0400")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gregory Haskins <ghaskins@novell.com> writes:

What might be useful is if you could expand a bit more on what the high level
use cases for this. 

Questions that come to mind and that would be good to answer:

This seems to be aimed at having multiple VMs talk
to each other, but not talk to the rest of the world, correct? 
Is that a common use case? 

Wouldn't they typically have a default route  anyways and be able to talk to each 
other this way? 
And why can't any such isolation be done with standard firewalling? (it's known that 
current iptables has some scalability issues, but there's work going on right
now to fix that). 

What would be the use cases for non networking devices?

How would the interfaces to the user look like?

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
