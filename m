From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for
	vbus_driver objects
Date: Mon, 17 Aug 2009 16:23:10 +0200
Message-ID: <20090817142310.GA3602@elte.hu>
References: <20090814154125.26116.70709.stgit@dev.haskins.net> <20090814154308.26116.46980.stgit@dev.haskins.net> <20090815103243.GA26749@elte.hu> <4A870964.9090408@codemonkey.ws> <20090816071607.GB29537@elte.hu> <4A896112.9030407@codemonkey.ws>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gregory Haskins <ghaskins@novell.com>, kvm@vger.kernel.org,
	Avi Kivity <avi@redhat.com>,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Anthony Liguori <anthony@codemonkey.ws>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4A896112.9030407@codemonkey.ws>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Anthony Liguori <anthony@codemonkey.ws> wrote:

> Ingo Molnar wrote:
>>> I think the reason vbus gets better performance for networking today 
>>> is that vbus' backends are in the kernel while virtio's backends are 
>>> currently in userspace.  Since Michael has a functioning in-kernel 
>>> backend for virtio-net now, I suspect we're weeks (maybe days) away 
>>> from performance results.  My expectation is that vhost + virtio-net 
>>> will be as good as venet + vbus.  If that's the case, then I don't 
>>> see any reason to adopt vbus unless Greg things there are other 
>>> compelling features over virtio.
>>>     
>>
>> Keeping virtio's backend in user-space was rather stupid IMHO.
>
> I don't think it's quite so clear.

in such a narrow quote it's not so clear indeed - that's why i 
qualified it with:

>> Having the _option_ to piggyback to user-space (for flexibility, 
>> extensibility, etc.) is OK, but not having kernel acceleration is 
>> bad.

	Ingo
