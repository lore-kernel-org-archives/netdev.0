From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Wed, 1 Apr 2009 13:40:39 -0700
Message-ID: <20090401204039.GR18394@sequoia.sous-sol.org>
References: <20090331184057.28333.77287.stgit@dev.haskins.net> <87ab71monw.fsf@basil.nowhere.org> <49D35825.3050001@novell.com> <20090401132340.GT11935@one.firstfloor.org> <49D37805.1060301@novell.com> <20090401170103.GU11935@one.firstfloor.org> <49D3B64F.6070703@codemonkey.ws>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	Gregory Haskins <ghaskins@novell.com>,
	linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Anthony Liguori <anthony@codemonkey.ws>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <49D3B64F.6070703@codemonkey.ws>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Anthony Liguori (anthony@codemonkey.ws) wrote:
> Andi Kleen wrote:
>> On Wed, Apr 01, 2009 at 10:19:49AM -0400, Gregory Haskins wrote:
>>> Performance.  We are trying to create a high performance IO infrastructure.
>>
>> Ok. So the goal is to bypass user space qemu completely for better
>> performance. Can you please put this into the initial patch
>> description?
>
> FWIW, there's nothing that prevents in-kernel back ends with virtio so  
> vbus certainly isn't required for in-kernel backends.

Indeed.

> That said, I don't think we're bound today by the fact that we're in  
> userspace.  Rather we're bound by the interfaces we have between the  
> host kernel and userspace to generate IO.  I'd rather fix those  
> interfaces than put more stuff in the kernel.

And more stuff in the kernel can come at the potential cost of weakening
protection/isolation.
