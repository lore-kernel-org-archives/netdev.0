From: Pavel Machek <pavel@suse.cz>
Subject: Re: ipw2100: more cleanups
Date: Mon, 4 Jul 2005 09:05:06 +0200
Message-ID: <20050704070506.GA15370@elf.ucw.cz>
References: <20050513214025.GA1863@elf.ucw.cz> <1120456146.27821.85.camel@debian.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jketreno@linux.intel.com, netdev@oss.sgi.com, jbohac@suse.cz,
        jbenc@suse.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: Zhu Yi <yi.zhu@intel.com>
Content-Disposition: inline
In-Reply-To: <1120456146.27821.85.camel@debian.sh.intel.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi!

> > More cleanups (relative to ipw2100-1.1.0 version). Highlights include
> > removing of two printk wrappers.
> 
> [snip]
> 
> > -static DEVICE_ATTR(bssinfo, S_IRUGO, show_bssinfo, NULL);
> 
> Any special reason to remove these driver sysfs entries?

Umm, yes, they should not be needed and we do not want to maintain
them in /sys forever. /sys should be "one value per file", and
definitely not for debugging stuff like this. (See debugfs)

Anyway I think I did drop that patch from newer cleanup attempts.

							Pavel
-- 
teflon -- maybe it is a trademark, but it should not be.
