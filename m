From: "Gregory Haskins" <ghaskins@novell.com>
Subject: Re: [PATCH 0/7] AlacrityVM guest drivers Reply-To:
Date: Thu, 06 Aug 2009 06:09:33 -0600
Message-ID: <4A7A8FBD0200005A00051B8A@sinclair.provo.novell.com>
References: <20090803171030.17268.26962.stgit@dev.haskins.net>
 <20090806081955.GA9752@redhat.com> <20090806101702.GA10605@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <alacrityvm-devel@lists.sourceforge.net>, <kvm@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20090806101702.GA10605@redhat.com>
Content-Disposition: inline
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>> On 8/6/2009 at  6:17 AM, in message <20090806101702.GA10605@redhat.com>,
"Michael S. Tsirkin" <mst@redhat.com> wrote: 
> On Thu, Aug 06, 2009 at 11:19:56AM +0300, Michael S. Tsirkin wrote:
>> On Mon, Aug 03, 2009 at 01:17:30PM -0400, Gregory Haskins wrote:
>> > (Applies to v2.6.31-rc5, proposed for linux-next after review is complete)
>> 
>> These are guest drivers, right? Merging the guest first means relying on
>> kernel interface from an out of tree driver, which well might change
>> before it goes in.  Would it make more sense to start merging with the
>> host side of the project?
>> 
>> > This series implements the guest-side drivers for accelerated IO
>> > when running on top of the AlacrityVM hypervisor, the details of
>> > which you can find here:
>> > 
>> > http://developer.novell.com/wiki/index.php/AlacrityVM
>> 
>> Since AlacrityVM is kvm based, Cc kvm@vger.kernel.org.
>> 
>> > This series includes the basic plumbing, as well as the driver for
>> > accelerated 802.x (ethernet) networking.
>> 
>> The graphs comparing virtio with vbus look interesting.
>> However, they do not compare apples to apples, do they?
>> These compare userspace virtio with kernel vbus, where for
>> apples to apples comparison one would need to compare
>> kernel virtio with kernel vbus. Right?
> 
> Or userspace virtio with userspace vbus.

Note: That would be pointless.

-Greg


