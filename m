From: Dave Jones <davej@redhat.com>
Subject: Re: Broadcom 43xx first results
Date: Mon, 5 Dec 2005 14:53:29 -0500
Message-ID: <20051205195329.GB19964@redhat.com>
References: <E1Eiyw4-0003Ab-FW@www1.emo.freenet-rz.de> <20051205190038.04b7b7c1@griffin.suse.cz> <4394892D.2090100@gentoo.org> <20051205195543.5a2e2a8d@griffin.suse.cz> <4394902C.8060100@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Benc <jbenc@suse.cz>, Joseph Jezak <josejx@gentoo.org>,
	mbuesch@freenet.de, linux-kernel@vger.kernel.org,
	bcm43xx-dev@lists.berlios.de, NetDev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964797AbVLETya@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <4394902C.8060100@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 05, 2005 at 02:08:28PM -0500, Jeff Garzik wrote:
 > Jiri Benc wrote:
 > >On Mon, 05 Dec 2005 13:38:37 -0500, Joseph Jezak wrote:
 > >
 > >>We're not writing an entire stack.  We're writing a layer that sits in 
 > >>between the current ieee80211 stack that's already present in the kernel 
 > >>and drivers that do not have a hardware MAC.  Since ieee80211 is already 
 > >>in use in the kernel today, this seemed like a natural and useful 
 > >>extension to the existing code.  I agree that it's somewhat wasteful to 
 > >>keep rewriting 802.11 stacks and we considered other options, but it 
 > >>seemed like a more logical choice to work with what was available and 
 > >>recommended than to use an external stack.
 > >
 > >
 > >Unfortunately, the only long-term solution is to rewrite completely the
 > >current in-kernel ieee80211 code (I would not call it a "stack") or
 > >replace it with something another. The current code was written for
 > >Intel devices and it doesn't support anything else - so every developer
 > 
 > Patently false.
 > 
 > ieee80211 is used by Intel.  Some bits used by HostAP, which also 
 > duplicates a lot of ieee80211 code.  And bcm43xx.  And another couple 
 > drivers found in -mm or out-of-tree.

Orinoco also uses it now no ?

		Dave
