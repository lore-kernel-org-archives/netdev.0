From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [Xen-devel] [RFC v2 1/4] bridge: enable interfaces to opt out
 from becoming the root bridge
Date: Mon, 17 Feb 2014 17:52:24 +0000
Message-ID: <53024C58.4010900@citrix.com>
References: <1392433180-16052-1-git-send-email-mcgrof@do-not-panic.com> <1392433180-16052-2-git-send-email-mcgrof@do-not-panic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <kvm@vger.kernel.org>, "Luis R. Rodriguez" <mcgrof@suse.com>,
	<bridge@lists.linux-foundation.org>,
	<linux-kernel@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	<xen-devel@lists.xenproject.org>
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	<netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1392433180-16052-2-git-send-email-mcgrof@do-not-panic.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 15/02/14 02:59, Luis R. Rodriguez wrote:
> From: "Luis R. Rodriguez" <mcgrof@suse.com>
>
> It doesn't make sense for some interfaces to become a root bridge
> at any point in time. One example is virtual backend interfaces
> which rely on other entities on the bridge for actual physical
> connectivity. They only provide virtual access.

It is possible that a guest bridge together to VIF, either from the same 
Dom0 bridge or from different ones. In that case using STP on VIFs sound 
sensible to me.

Zoli
