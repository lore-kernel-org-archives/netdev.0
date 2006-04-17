From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 12/18] ipw2200: version string rework
Date: Mon, 17 Apr 2006 09:37:45 -0700
Message-ID: <20060417093745.6e76b957@localhost.localdomain>
References: <20060413092034.GA28787@mail.intel.com>
	<20060413102820.4fabf028@localhost.localdomain>
	<4443C2EE.6030302@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yi.zhu@intel.com, netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:18632 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751141AbWDQQht (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2006 12:37:49 -0400
To: James Ketrenos <jketreno@linux.intel.com>
In-Reply-To: <4443C2EE.6030302@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 17 Apr 2006 11:31:42 -0500
James Ketrenos <jketreno@linux.intel.com> wrote:

> Stephen Hemminger wrote:
> > On Thu, 13 Apr 2006 17:20:34 +0800
> > Zhu Yi <yi.zhu@intel.com> wrote:
> > 
> > 
> >>Added version string fields so the version string indicates what is
> >>configured (ie, you'll see 1.1.1kpmd if you are using a GIT snapshot
> >>(Kernel.. previously -git), promiscuous (p), monitor (m), debug (d) build.
> > 
> > 
> > No, this is completely the wrong direction.
> > 
> > Stop with the config option nonsense. It makes it impossible for linux distributions
> > and others that want to ship one kernel and modules.
> 
> How does it make it impossible for someone to ship one kernel?
> 
> There are are various configuration options to enable, some of which are
> experimental and/or unstable, some add code and/or impact performance
> when enabled, etc.  Not all users want all features.
> 
> Easily determining what is enabled in the driver is a requirement.
> 
> The distributors should default to not enabling any feature that does
> not default to =y or =m in Kconfig.  In the default configuration, there
> shouldn't be any post-fix fields appended to the version string.  If
> there is, we need to either fix the version string or the default
> Kconfig setting.
> 
> Is there an alternative method for quickly and easily determining what
> all features are enabled in a module--even if the module isn't loaded?
> We didn't see one, and using the fields post-fixed to the version string
> has quickly resolved various support issues.
> 
> Thanks,
> James

The version string is good idea, it is just the NxM complexity of possibilities
that gets nasty.  Also, is this a permanent fixture of these drivers, or just
some transitional stage as new features get added that aren't stable yet?
