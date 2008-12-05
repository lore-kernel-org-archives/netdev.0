From: James Morris <jmorris@namei.org>
Subject: Re: [E1000-devel] networking probs in next-20081203
Date: Fri, 5 Dec 2008 13:03:08 +1100 (EST)
Message-ID: <alpine.LRH.1.10.0812051243190.11818@tundra.namei.org>
References: <49381644.8020502@intel.com> <20081204175236.GA19808@x200.localdomain> <1228414280.11091.54.camel@moss-spartans.epoch.ncsc.mil> <20081204.102138.123959105.davem@davemloft.net> <1228419142.11091.90.camel@moss-spartans.epoch.ncsc.mil>
 <1228421219.11091.94.camel@moss-spartans.epoch.ncsc.mil> <m1bpvrslk0.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Stephen Smalley <sds@tycho.nsa.gov>,
	David Miller <davem@davemloft.net>, adobriyan@gmail.com,
	auke-jan.h.kok@intel.com, akpm@linux-foundation.org,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	eparis@parisplace.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tundra.namei.org ([65.99.196.166]:56785 "EHLO tundra.namei.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752201AbYLECDx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Dec 2008 21:03:53 -0500
In-Reply-To: <m1bpvrslk0.fsf@frodo.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 4 Dec 2008, Eric W. Biederman wrote:

> Which piece of selinux magic did I miss?

The problem is that SELinux doesn't know anything about the new filesystem 
type, and specifically, to treat it like procfs.  There are a couple 
workarounds we can try to prevent this specific problem from cropping up 
again.

> In particular can you tell if this was a code bug or a logic bug?

I wouldn't say it was a bug, more a consequence of necessarily imperfect 
encapsulation of the security code via LSM.  It's just something we have to 
keep an eye out for.



- James
-- 
James Morris
<jmorris@namei.org>
