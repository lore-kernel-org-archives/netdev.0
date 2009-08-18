From: Avi Kivity <avi@redhat.com>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for	vbus_driver
 objects
Date: Tue, 18 Aug 2009 13:00:25 +0300
Message-ID: <4A8A7BB9.2020906@redhat.com>
References: <20090814154125.26116.70709.stgit@dev.haskins.net> <20090814154308.26116.46980.stgit@dev.haskins.net> <20090815103243.GA26749@elte.hu> <4A8954F0.3040402@gmail.com> <20090817142506.GB3602@elte.hu> <4A8971A8.2040102@gmail.com> <20090817150844.GA3307@elte.hu> <4A89B08A.4010103@gmail.com> <20090818095313.GC13878@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Gregory Haskins <gregory.haskins@gmail.com>,
	Ingo Molnar <mingo@elte.hu>,
	Gregory Haskins <ghaskins@novell.com>, kvm@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20090818095313.GC13878@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/18/2009 12:53 PM, Michael S. Tsirkin wrote:
> I'm not hung up on PCI, myself.  An idea that might help you get Avi
> on-board: do setup in userspace, over PCI.  Negotiate hypercall support
> (e.g.  with a PCI capability) and then switch to that for fastpath. Hmm?
>    

Hypercalls don't nest well.  When a nested guest issues a hypercall, you 
have to assume it is destined to the enclosing guest, so you can't 
assign a hypercall-capable device to a nested guest.

mmio and pio don't have this problem since the host can use the address 
to locate the destination.

-- 
error compiling committee.c: too many arguments to function

