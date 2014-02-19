From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [Xen-devel] [RFC v2 4/4] xen-netback: skip IPv4 and IPv6
 interfaces
Date: Wed, 19 Feb 2014 09:47:21 +0000
Message-ID: <1392803241.23084.94.camel@kazak.uk.xensource.com>
References: <1392433180-16052-1-git-send-email-mcgrof@do-not-panic.com>
	 <1392433180-16052-5-git-send-email-mcgrof@do-not-panic.com>
	 <53021E87.6020607@citrix.com>
	 <CAB=NE6WwPfPi-8Yudxs4-OA2LPOjo8-XxUiVbtu6=BQ8FhEEOA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>, <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Paul Durrant <Paul.Durrant@citrix.com>,
	<xen-devel@lists.xenproject.org>
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAB=NE6WwPfPi-8Yudxs4-OA2LPOjo8-XxUiVbtu6=BQ8FhEEOA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-02-18 at 12:16 -0800, Luis R. Rodriguez wrote:
> On Mon, Feb 17, 2014 at 6:36 AM, Zoltan Kiss <zoltan.kiss@citrix.com> wrote:
> > Also, the backend is not necessarily Dom0, you can connect two guests with
> > backend/frontend pairs.
> 
> Can you elaborate a bit more on this type of setup?

The domain providing backend networking services is not necessarily
dom0, it might be a driver domain:
http://wiki.xen.org/wiki/Driver_Domain

I think from your PoV here it probably doesn't matter whether the driver
domain is dom0 or some other domain.

Ian.
