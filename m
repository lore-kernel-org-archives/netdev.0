From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: 8% performance improved by change tap interact with kernel stack
Date: Wed, 29 Jan 2014 09:56:30 +0200
Message-ID: <20140129075630.GC23228@redhat.com>
References: <52E766D4.4070901@huawei.com>
 <20140128083459.GB16833@redhat.com>
 <52E77506.1080604@huawei.com>
 <20140128094138.GA17332@redhat.com>
 <52E78416.50000@huawei.com>
 <20140128103325.GA17794@redhat.com>
 <52E8B0A4.6030806@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jasowang@redhat.com, Anthony Liguori <anthony@codemonkey.ws>,
	KVM list <kvm@vger.kernel.org>, netdev@vger.kernel.org
To: Qin Chuanyu <qinchuanyu@huawei.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <52E8B0A4.6030806@huawei.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 29, 2014 at 03:41:24PM +0800, Qin Chuanyu wrote:
> On 2014/1/28 18:33, Michael S. Tsirkin wrote:
> 
> >>>Nice.
> >>>What about CPU utilization?
> >>>It's trivially easy to speed up networking by
> >>>burning up a lot of CPU so we must make sure it's
> >>>not doing that.
> >>>And I think we should see some tests with TCP as well, and
> >>>try several message sizes.
> >>>
> >>>
> >>Yes, by burning up more CPU we could get better performance easily.
> >>So I have bond vhost thread and interrupt of nic on CPU1 while testing.
> >>
> >>modified before, the idle of CPU1 is 0%-1% while testing.
> >>and after modify, the idle of CPU1 is 2%-3% while testing
> >>
> >>TCP also could gain from this, but pps is less than UDP, so I think
> >>the improvement would be not so obviously.
> >
> >Still need to test this doesn't regress but overall looks convincing to me.
> >Could you send a patch, accompanied by testing results for
> >throughput latency and cpu utilization for tcp and udp
> >with various message sizes?
> >
> >Thanks!
> >
> because of spring festival of china, the test result would be given
> two week later.
> throughput would be test by netperf, and latency would be tested by
> qperf. Is that OK?

For testing - sounds good. Run vmstat in host to check host cpu utilization.
Pls don't forget to address all issues raised in this thread and in
the old one Eric mentioned:
http://patchwork.ozlabs.org/patch/52963/
either address in code or address in commit log why it doesn't apply
anymore.

-- 
MST
