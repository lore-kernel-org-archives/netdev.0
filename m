From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for
	vbus_driver objects
Date: Mon, 17 Aug 2009 17:05:38 +0200
Message-ID: <20090817150538.GA12346@elte.hu>
References: <20090814154125.26116.70709.stgit@dev.haskins.net> <20090814154308.26116.46980.stgit@dev.haskins.net> <20090815103243.GA26749@elte.hu> <4A870964.9090408@codemonkey.ws> <4A8965E0.8050608@gmail.com> <4A896FFE.5050207@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gregory Haskins <gregory.haskins@gmail.com>,
	Anthony Liguori <anthony@codemonkey.ws>,
	Gregory Haskins <ghaskins@novell.com>, kvm@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Avi Kivity <avi@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:42072 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755529AbZHQPGA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Aug 2009 11:06:00 -0400
Content-Disposition: inline
In-Reply-To: <4A896FFE.5050207@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Avi Kivity <avi@redhat.com> wrote:

> I don't have any technical objections to vbus/venet (I had in the 
> past re interrupts but I believe you've addressed them), and it 
> appears to perform very well.  However I still think we should 
> address virtio's shortcomings (as Michael is doing) rather than 
> create a competitor.  We have enough external competition, we 
> don't need in-tree competitors.

I do have strong technical objections: distributions really want to 
standardize on as few Linux internal virtualization APIs as 
possible, so splintering it just because /bin/cp is easy to do is 
bad.

If virtio pulls even with vbus's performance and vbus has no 
advantages over virtio i do NAK vbus on that basis. Lets stop the 
sillyness before it starts hurting users. Coming up with something 
better is good, but doing an incompatible, duplicative framework 
just for NIH reasons is stupid and should be resisted.

People dont get to add a new sys_read_v2() without strong technical 
arguments either - the same holds for our Linux internal driver 
abstractions, APIs and ABIs.

	ingo
