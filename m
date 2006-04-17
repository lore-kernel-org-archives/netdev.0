From: James Ketrenos <jketreno@linux.intel.com>
Subject: Re: [PATCH 12/18] ipw2200: version string rework
Date: Mon, 17 Apr 2006 11:31:42 -0500
Message-ID: <4443C2EE.6030302@linux.intel.com>
References: <20060413092034.GA28787@mail.intel.com> <20060413102820.4fabf028@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yi.zhu@intel.com, netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr20.intel.com ([134.134.136.19]:48086 "EHLO
	orsfmr005.jf.intel.com") by vger.kernel.org with ESMTP
	id S1750779AbWDQQ3q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Apr 2006 12:29:46 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060413102820.4fabf028@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Thu, 13 Apr 2006 17:20:34 +0800
> Zhu Yi <yi.zhu@intel.com> wrote:
> 
> 
>>Added version string fields so the version string indicates what is
>>configured (ie, you'll see 1.1.1kpmd if you are using a GIT snapshot
>>(Kernel.. previously -git), promiscuous (p), monitor (m), debug (d) build.
> 
> 
> No, this is completely the wrong direction.
> 
> Stop with the config option nonsense. It makes it impossible for linux distributions
> and others that want to ship one kernel and modules.

How does it make it impossible for someone to ship one kernel?

There are are various configuration options to enable, some of which are
experimental and/or unstable, some add code and/or impact performance
when enabled, etc.  Not all users want all features.

Easily determining what is enabled in the driver is a requirement.

The distributors should default to not enabling any feature that does
not default to =y or =m in Kconfig.  In the default configuration, there
shouldn't be any post-fix fields appended to the version string.  If
there is, we need to either fix the version string or the default
Kconfig setting.

Is there an alternative method for quickly and easily determining what
all features are enabled in a module--even if the module isn't loaded?
We didn't see one, and using the fields post-fixed to the version string
has quickly resolved various support issues.

Thanks,
James
