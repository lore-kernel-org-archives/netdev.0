From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [RFC v2 0/4] net: bridge / ip optimizations for virtual
 net backends
Date: Mon, 17 Feb 2014 10:27:29 +0000
Message-ID: <5301E411.5060908@citrix.com>
References: <1392433180-16052-1-git-send-email-mcgrof@do-not-panic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
	"Luis R. Rodriguez" <mcgrof@suse.com>,
	<linux-kernel@vger.kernel.org>, <kvm@vger.kernel.org>
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1392433180-16052-1-git-send-email-mcgrof@do-not-panic.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 15/02/14 02:59, Luis R. Rodriguez wrote:
> From: "Luis R. Rodriguez" <mcgrof@suse.com>
> 
> This v2 series changes the approach from my original virtualization
> multicast patch series [0] by abandoning completely the multicast
> issues and instead generalizing an approach for virtualization
> backends. There are two things in common with virtualization
> backends:
> 
>   0) they should not become the root bridge
>   1) they don't need ipv4 / ipv6 interfaces

Why?  There's no real difference between a backend network device and a
physical device (from the point of view of the backend domain).  I do
not think these are intrinsic properties of backend devices.

I can see these being useful knobs for administrators (or management
toolstacks) to turn on, on a per-device basis.

David
