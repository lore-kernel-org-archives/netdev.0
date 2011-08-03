From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH RFC net-next] virtio_net: refill buffer right after being
 used
Date: Wed, 3 Aug 2011 23:30:20 +0300
Message-ID: <20110803203020.GB19501@redhat.com>
References: <1311979448.24300.28.camel@localhost.localdomain>
 <1311980131.24300.30.camel@localhost.localdomain>
 <CAGTjWtCsgcf664HJ_prmcRyUzLcSSKhjfbaM0KnsxhDJo6k7Fg@mail.gmail.com>
 <1312089375.23194.11.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mike Waychison <mikew@google.com>,
	Rusty Russell <rusty@rustcorp.com.au>, kvm@vger.kernel.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1312089375.23194.11.camel@localhost.localdomain>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 30, 2011 at 10:16:15PM -0700, Shirley Ma wrote:
> It averages the latency between each receive by filling only one set of
> buffers vs. either none buffers or 1/2 ring size buffers fill between
> receives.

I see how the overhead of allocating memory is spread more evenly.  Does this
actually help some workloads?
