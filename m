From: Jeff Moyer <jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: 2.6.30-rc deadline scheduler performance regression for iozone over NFS
Date: Mon, 18 May 2009 10:15:22 -0400
Message-ID: <x49tz3ia45h.fsf@segfault.boston.devel.redhat.com>
References: <x49hc0f79k9.fsf@segfault.boston.devel.redhat.com>
	<20090508120119.8c93cfd7.akpm@linux-foundation.org>
	<20090511081415.GL4694@kernel.dk>
	<x49skjb21b7.fsf@segfault.boston.devel.redhat.com>
	<20090511165826.GG4694@kernel.dk>
	<x494ovp4r51.fsf@segfault.boston.devel.redhat.com>
	<20090512204433.7eb69075.akpm@linux-foundation.org>
	<x49y6t1rqw0.fsf@segfault.boston.devel.redhat.com>
	<x49k54ku7i2.fsf@segfault.boston.devel.redhat.com>
	<1242258338.5407.244.camel@heimdal.trondhjem.org>
	<x49octv7qr8.fsf@segfault.boston.devel.redhat.com>
	<1242311620.6560.14.camel@heimdal.trondhjem.org>
	<x49ws8j686r.fsf@segfault.boston.devel.redhat.com>
	<1242587454.17796.2.camel@heimdal.trondhjem.org>
	<1242587524.17796.3.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	Olga Kornievskaia <aglo-vtMw8L3fJ9vSiEDVxGk4TQ@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Jim Rees <rees-63aXycvo3TyHXe+LvDLADg@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1242587524.17796.3.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org> (Trond
	Myklebust's message of "Sun, 17 May 2009 15:12:04 -0400")
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org> writes:

> On Sun, 2009-05-17 at 15:11 -0400, Trond Myklebust wrote:
>> On Thu, 2009-05-14 at 11:00 -0400, Jeff Moyer wrote:
>> > Sorry for the previous, stupid question.  I applied the patch in
>> > addition the last one and here are the results:
>> > 
>> > 70327
>> > 71561
>> > 68760
>> > 69199
>> > 65324
>> > 
>> > A packet capture for this run is available here:
>> >   http://people.redhat.com/jmoyer/trond2.pcap.bz2
>> > 
>> > Any more ideas?  ;)
>> 
>> Yep. I've got 2 more patches for you. With both of them applied, I'm
>> seeing decent performance on my own test rig. The first patch is
>> appended. I'll send the second in another email (to avoid attachments).
>
> Here is number 2. It is incremental to all the others...

With all 4 patches applied, these are the numbers for 5 runs:

103168
101212
103346
100842
103172

It's looking much better, but we're still off by a few percent.  Thanks
for the quick turnaround on this, Trond!  If you submit these patches,
feel free to add:

Tested-by: Jeff Moyer <jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Cheers,
Jeff
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
