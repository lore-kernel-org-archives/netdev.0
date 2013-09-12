From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCHSET] sysfs: disentangle kobject namespace handling from sysfs
Date: Wed, 11 Sep 2013 20:37:23 -0700
Message-ID: <87li324sng.fsf@xmission.com>
References: <1378952949-7900-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
	kay@vrfy.org, netdev@vger.kernel.org, lizefan@huawei.com
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1378952949-7900-1-git-send-email-tj@kernel.org> (Tejun Heo's
	message of "Wed, 11 Sep 2013 22:29:02 -0400")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tejun Heo <tj@kernel.org> writes:

> Hello,
>
> I'll send out multiple patchsets to separate out sysfs from driver
> core and kobject.  The eventual goal is making sysfs modular enough so
> that cgroup can replace its nightmarish cgroupfs implementation which
> repeated and worsened all the past mistakes of sysfs.  This patchset
> is first of the effort and separates out kobject namespace handling
> from sysfs.

At a practical level you probably just want to copy the good parts of
the structure of sysfs, instead of attempting to share code.

Sharing code is likely to get you into all kinds of problems with short
term hacks.

> I never really understood why namespace support was added the way it
> was added.  Namespace information is communicated to sysfs via
> callbacks and back-queries to upper layer, which is a very unusual and
> weird thing to do when all the involved operations are synchronous.
> For example, a tagged attribute creation looks like the following.

Then please ask.

I don't have the time or energy to review these right now, and given the
sweeping nature of the patches, and the dismissive attitude of the
original design there is almost at least one stupid bug if not something
worse.

So until I have the energy to review these.

Nacked-by: "Eric W. Biederman" <ebiederm@xmission.com>

I am sorry but I don't have time to clean up after any more people
touching sysfs when the break something.  It does look like there are so
possibly good things going on but..

Eric
