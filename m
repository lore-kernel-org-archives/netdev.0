From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 12/15] driver core: Implement tagged directory support for device classes.
Date: Fri, 18 Jul 2008 13:19:55 -0700
Message-ID: <m1tzenhrmc.fsf@frodo.ebiederm.org>
References: <m1mykyh2fu.fsf_-_@frodo.ebiederm.org>
	<m1hcb6h2d2.fsf_-_@frodo.ebiederm.org> <486DD650.3000804@gmail.com>
	<m1tzf593ny.fsf@frodo.ebiederm.org> <486E2C3B.6020603@gmail.com>
	<20080704161200.GA1440@suse.de> <m1lk052ptp.fsf@frodo.ebiederm.org>
	<487D6A24.9070001@gmail.com> <20080717230857.GB28377@suse.de>
	<48808F79.7080607@gmail.com> <20080718184936.GA21343@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tejun Heo <htejun@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	linux-kernel@vger.kernel.org, Al Viro <viro@ftp.linux.org.uk>,
	Linux Containers <containers@lists.osdl.org>,
	Benjamin Thery <benjamin.thery@bull.net>,
	netdev@vger.kernel.org
To: Greg KH <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:44161 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751814AbYGRUWa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 16:22:30 -0400
In-Reply-To: <20080718184936.GA21343@suse.de> (Greg KH's message of "Fri, 18
	Jul 2008 11:49:36 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greg KH <gregkh@suse.de> writes:

> On Fri, Jul 18, 2008 at 09:41:29PM +0900, Tejun Heo wrote:
>> Greg KH wrote:
>> > Ok, I'll work to get these in where applicable.
>> 
>> Did this get into 2.6.27?  Or will this have to wait till .28?
>
> I haven't sent any patches to Linus yet for 2.6.27, so it hasn't gotten
> there yet.
>
> And due to the intrusiveness, and the fact that this hasn't been tested
> at all in any build tree yet, I can't in good concious submit this for
> .27 either.
>
> Part of this is my fault, I know, due to vacation and work, but also
> lots is due to the fact that the code showed up so late in the
> development cycle.

The code showed up at least by the beginning of may, and the code has
been around for 9 months or more.  I just haven't always had the
energy to retransmit every time it has gotten dropped.  The last spin
of it was very late I agree.

> I'll add it to my tree, and get it some testing in the next cycle of
> linux-next until 2.6.27 is out, and then if it's still looking good, go
> into .28.

I think that is unnecessarily precautions but reasonable.  That should at
least keep other sysfs patches from coming in and causing bit rot.

Eric

