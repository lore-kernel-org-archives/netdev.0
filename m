From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC] Virtual Machine Device Queues(VMDq) support on KVM
Date: Tue, 22 Sep 2009 13:38:07 +0300
Message-ID: <20090922103807.GA2555@redhat.com>
References: <C85CEDA13AB1CF4D9D597824A86D2B9006AEB94861@PDSMSX501.ccr.corp.intel.com> <20090901090518.1193e412@nehalam> <200909211637.23299.rusty@rustcorp.com.au> <20090921092130.30984dbd@s6510> <20090921162718.GM26034@sequoia.sous-sol.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
        Rusty Russell <rusty@rustcorp.com.au>,
        virtualization@lists.linux-foundation.org,
        "Xin, Xiaohui" <xiaohui.xin@intel.com>,
        "kvm@vger.kernel.org" <kvm@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "hpa@zytor.com" <hpa@zytor.com>, "mingo@elte.hu" <mingo@elte.hu>,
        "akpm@linux-foundation.org" <akpm@linux-foundation.org>
To: Chris Wright <chrisw@sous-sol.org>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <20090921162718.GM26034@sequoia.sous-sol.org>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 21, 2009 at 09:27:18AM -0700, Chris Wright wrote:
> * Stephen Hemminger (shemminger@vyatta.com) wrote:
> > On Mon, 21 Sep 2009 16:37:22 +0930
> > Rusty Russell <rusty@rustcorp.com.au> wrote:
> > 
> > > > > Actually this framework can apply to traditional network adapters which have
> > > > > just one tx/rx queue pair. And applications using the same user/kernel interface
> > > > > can utilize this framework to send/receive network traffic directly thru a tx/rx
> > > > > queue pair in a network adapter.
> > > > > 
> > 
> > More importantly, when virtualizations is used with multi-queue
> > NIC's the virtio-net NIC is a single CPU bottleneck. The virtio-net
> > NIC should preserve the parallelism (lock free) using multiple
> > receive/transmit queues. The number of queues should equal the
> > number of CPUs.
> 
> Yup, multiqueue virtio is on todo list ;-)
> 
> thanks,
> -chris

Note we'll need multiqueue tap for that to help.

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
