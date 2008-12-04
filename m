From: David Miller <davem@davemloft.net>
Subject: Re: [E1000-devel] networking probs in next-20081203
Date: Thu, 04 Dec 2008 10:21:38 -0800 (PST)
Message-ID: <20081204.102138.123959105.davem@davemloft.net>
References: <49381644.8020502@intel.com>
	<20081204175236.GA19808@x200.localdomain>
	<1228414280.11091.54.camel@moss-spartans.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: adobriyan@gmail.com, auke-jan.h.kok@intel.com,
	akpm@linux-foundation.org, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, ebiederm@xmission.com, jmorris@namei.org,
	eparis@parisplace.org
To: sds@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55908
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753891AbYLDSVi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 13:21:38 -0500
In-Reply-To: <1228414280.11091.54.camel@moss-spartans.epoch.ncsc.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Smalley <sds@tycho.nsa.gov>
Date: Thu, 04 Dec 2008 13:11:20 -0500

> On Thu, 2008-12-04 at 20:52 +0300, Alexey Dobriyan wrote:
> > On Thu, Dec 04, 2008 at 09:41:24AM -0800, Kok, Auke wrote:
> > > maybe try disabling selinux?
> > 
> > This will work. :^)
> 
> SELinux didn't change here.  /proc/net did.

We've been through this before...

And it is a usability issue that people can't change how procfs
directories work without requiring the user to update their selinux
policies first.
