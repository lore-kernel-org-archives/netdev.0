From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [Xen-devel] [RFC v2 0/4] net: bridge / ip optimizations for
 virtual net backends
Date: Wed, 19 Feb 2014 09:48:24 +0000
Message-ID: <1392803304.23084.95.camel@kazak.uk.xensource.com>
References: <1392433180-16052-1-git-send-email-mcgrof@do-not-panic.com>
	 <5301E411.5060908@citrix.com>
	 <CAB=NE6VxNByeWGk6_Ow7WgxA3HCwGBjrjL9MNVRGsEfFyeKTdw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Vrabel <david.vrabel@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	<kvm@vger.kernel.org>, <xen-devel@lists.xenproject.org>
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAB=NE6VxNByeWGk6_Ow7WgxA3HCwGBjrjL9MNVRGsEfFyeKTdw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-02-18 at 11:43 -0800, Luis R. Rodriguez wrote:
> 
> New motivation: removing IPv4 and IPv6 from the backend interfaces can
> save up a lot of boiler plate run time code, triggers from ever taking
> place, and simplifying the backend interaces. If there is no use for
> IPv4 and IPv6 interfaces why do we have them? Note: I have yet to test
> the NAT case.

I think you need to do that test that before you can unequivocally state
that there is no use for IPv4/6 interfaces here.

Ian.
