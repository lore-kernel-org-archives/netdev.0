From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Tue, 22 Dec 2009 08:59:27 +0100
Message-ID: <20091222075927.GC26467@elte.hu>
References: <4B1D4F29.8020309@gmail.com>
 <20091218215107.GA14946@elte.hu>
 <4B2F9582.5000002@gmail.com>
 <4B2F978D.7010602@redhat.com>
 <4B2F9C85.7070202@gmail.com>
 <4B2FA42F.3070408@codemonkey.ws>
 <4B2FA655.6030205@gmail.com>
 <4B2FAE7B.9030005@codemonkey.ws>
 <4B2FB3F1.5080808@gmail.com>
 <4B300EF8.8010602@codemonkey.ws>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gregory Haskins <gregory.haskins@gmail.com>,
	Avi Kivity <avi@redhat.com>, kvm@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>
To: Anthony Liguori <anthony@codemonkey.ws>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753108AbZLVIAP@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B300EF8.8010602@codemonkey.ws>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Anthony Liguori <anthony@codemonkey.ws> wrote:

> It's important to understand why one mechanism is better than another.  All 
> I'm looking for is a set of bullet points that say, vbus does this, 
> vhost-net does that, therefore vbus is better.  We would then either say, 
> oh, that's a good idea, let's change vhost-net to do that, or we would say, 
> hrm, well, we can't change vhost-net to do that because of some fundamental 
> flaw, let's drop it and adopt vbus.
> 
> It's really that simple :-)

That makes a lot of sense to me.

I think we better have damn good technical reasons before we encourage a fork 
of a subsystem within the kernel. Technical truth is not something we can 
'agree to disagree' on, and it is not something we can compromise on really.  

Both the host and the guest code is in Linux so adding another variant without 
that variant replacing the old one (on the spot or gradually) makes no 
technical sense.

Gregory, i'd suggest for you to shape this as a "this and this aspect of KVM 
needs to be replaced/fixed" list of items, as suggested by Anthony. In my 
experience the KVM folks are very approachable and very reasonable about 
addressing technical shortcomings and acting upon feedback (and are happily 
accepting code as well) - so to the extent there's room for improvement here 
it should be done by shaping KVM, not by forking and rebranding it.

	Ingo
