From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PATCH 12/15] driver core: Implement tagged directory support
 for device classes.
Date: Wed, 16 Jul 2008 12:25:24 +0900
Message-ID: <487D6A24.9070001@gmail.com>
References: <m18wwiihbn.fsf_-_@frodo.ebiederm.org>	<m14p76ih9a.fsf_-_@frodo.ebiederm.org>	<m1zloyh2mb.fsf_-_@frodo.ebiederm.org>	<m1vdzmh2jr.fsf_-_@frodo.ebiederm.org>	<m1r6aah2hh.fsf_-_@frodo.ebiederm.org>	<m1mykyh2fu.fsf_-_@frodo.ebiederm.org>	<m1hcb6h2d2.fsf_-_@frodo.ebiederm.org> <486DD650.3000804@gmail.com>	<m1tzf593ny.fsf@frodo.ebiederm.org> <486E2C3B.6020603@gmail.com>	<20080704161200.GA1440@suse.de> <m1lk052ptp.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Greg KH <gregkh@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	linux-kernel@vger.kernel.org, Al Viro <viro@ftp.linux.org.uk>,
	Linux Containers <containers@lists.osdl.org>,
	Benjamin Thery <benjamin.thery@bull.net>,
	netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.188]:4167 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753749AbYGPDZg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 23:25:36 -0400
Received: by ti-out-0910.google.com with SMTP id b6so2838657tic.23
        for <netdev@vger.kernel.org>; Tue, 15 Jul 2008 20:25:34 -0700 (PDT)
In-Reply-To: <m1lk052ptp.fsf@frodo.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman wrote:
> Greg KH <gregkh@suse.de> writes:
>> Sorry, Greg is walking out the door in 30 minutes for a much needed week
>> long vacation and can't look into this right now :(
>>
>> I'll be able to review it next weekend, sorry for the delay.
> 
> Any progress in reviewing these changes, and seeing if you can stand
> to merge them?

Greg, please disregard my earlier NACKs and commit the patches if you're
okay with them.  I'm working on cleaning it up but I don't think I'll be
able to make it in time for merge window and as Eric said getting the
functionality in place is more important at this point as it doesn't
affect user visible interface.

Eric, with the multiple superblocks, sysfs now uses inode from the
default sysfs_sb with dentries from other sb's.  Is this okay?  Are
there any other filesystems which do this?

Thanks.

-- 
tejun
