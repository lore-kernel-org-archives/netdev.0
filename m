From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCHSET] sysfs: disentangle kobject namespace handling from
 sysfs
Date: Wed, 11 Sep 2013 21:17:25 -0700
Message-ID: <20130912041725.GA6252@kroah.com>
References: <1378952949-7900-1-git-send-email-tj@kernel.org>
 <20130912031912.GA9773@kroah.com>
 <87eh8u4slj.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org,
	kay@vrfy.org, netdev@vger.kernel.org, lizefan@huawei.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87eh8u4slj.fsf@xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 11, 2013 at 08:38:32PM -0700, Eric W. Biederman wrote:
> Greg KH <gregkh@linuxfoundation.org> writes:
> 
> > On Wed, Sep 11, 2013 at 10:29:02PM -0400, Tejun Heo wrote:
> >> Hello,
> >> 
> >> I'll send out multiple patchsets to separate out sysfs from driver
> >> core and kobject.  The eventual goal is making sysfs modular enough so
> >> that cgroup can replace its nightmarish cgroupfs implementation which
> >> repeated and worsened all the past mistakes of sysfs.  This patchset
> >> is first of the effort and separates out kobject namespace handling
> >> from sysfs.
> >> 
> >> I never really understood why namespace support was added the way it
> >> was added.
> >
> > I just took the patches and didn't ask questions :)
> 
> Greg you don't get to play dumb you asked questions and required most of
> the current strucuture of the code.

I did?  Ok, I'll buy that, but please review this code for what it is,
nice cleanups and a sanity-check for the ns support in sysfs.  It saves
100+ lines of code, what's wrong with that?

> The code is convoluted by your request.

I really asked for the existing callback chain to look like that?  I did
want ns to be "minimal" in sysfs as I didn't think it was going to be a
good idea, and hoped it would go away.  Much like all other kernel
maintainers did for cgroups.  Turns out, we were wrong, and now Tejun is
stepping up and fixing it.

So, if I asked for this before, I apologize, I was wrong.  Just like I
was wrong about containers and cgroups, and I'll probably be wrong about
something else in the future.

greg k-h
