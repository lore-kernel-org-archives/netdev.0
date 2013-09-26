From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 7/7] sysfs: @name comes before @ns
Date: Thu, 26 Sep 2013 15:32:59 -0700
Message-ID: <20130926223259.GA29433@kroah.com>
References: <1378952949-7900-1-git-send-email-tj@kernel.org>
 <1378952949-7900-8-git-send-email-tj@kernel.org>
 <87a9ji4sk0.fsf@xmission.com>
 <20130912034943.GB4723@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	linux-kernel@vger.kernel.org, kay@vrfy.org, netdev@vger.kernel.org,
	lizefan@huawei.com
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130912034943.GB4723@mtj.dyndns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 11, 2013 at 11:49:43PM -0400, Tejun Heo wrote:
> Hello, Eric.
> 
> On Wed, Sep 11, 2013 at 08:39:27PM -0700, Eric W. Biederman wrote:
> > @ns is more significant so it should come first.
> > 
> > Where do we have the backwards convention of putting @name first?
> 
> Because @ns is optional and you end up with stupid stuff like
> 
> 	sysfs_xxx_ns(@param, @ns, @name)
> 	sysfs_xxx(@param, @name)
> 
> You put optional params after the mandatory ones.  It may be difficult
> to accept for you but @ns is a *clearly* optional thing for sysfs.

Sorry Eric, but I agree with Tejun here, the optional part is @ns, not
name, so it should go at the end.

thanks,

greg k-h
