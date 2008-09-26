From: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>
Subject: Re: e1000e NVM corruption issue status
Date: Thu, 25 Sep 2008 22:44:45 -0700
Message-ID: <4807377b0809252244j73b241e9nebd3d34cf138b214@mail.gmail.com>
References: <987CEB09A2567F4A963E1E226364E2D33A685B4B@orsmsx418.amr.corp.intel.com>
	 <Pine.WNT.4.63.0809251811330.1736@jbrandeb-desk.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	"Jiri Kosina" <jkosina@suse.cz>, agospoda@redhat.com,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Graham, David" <david.graham@intel.com>, kkiel@suse.de,
	tglx@linutronix.de, chris.jones@canonical.com,
	arjan@linux.jf.intel.com, "NetDEV list" <netdev@vger.kernel.org>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.228]:31657 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752542AbYIZFoq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2008 01:44:46 -0400
Received: by rv-out-0506.google.com with SMTP id k40so828204rvb.1
        for <netdev@vger.kernel.org>; Thu, 25 Sep 2008 22:44:45 -0700 (PDT)
In-Reply-To: <Pine.WNT.4.63.0809251811330.1736@jbrandeb-desk.amr.corp.intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm apparently in too much of a hurry, including netdev...

On Thu, Sep 25, 2008 at 6:50 PM, Brandeburg, Jesse
<jesse.brandeburg@intel.com> wrote:
> A quick summary of the issue, if you think you have more data, please
> reply.  If you have had this issue, please reply with results of "cat
> /proc/iomem" and "lspci".  It will help us correlate data.
>
> Problem: some users report that with many of the latest beta distros,
> during a reboot when e1000e loads it says "NVM checksum is not valid" and
> the driver fails to load.
>
> Result: At this point it appears that most users can load the e1000e
> driver if they skip the nvm validation error exit.  LAN traffic may or may
> not work at this point.  Some users report they can dump their eeprom
> using ethtool -e and see some varying data, most report the eeprom read
> returns all ff ff ff
>
> NOTE: if you have not had this problem, but wish to continue using e1000e
> I strongly suggest you do a "ethtool -e eth0 > savemyeep.txt"
>
> Many of the reports seem to be related in time to a graphics crash, no one
> has been able to give us more detail about how to reproduce.  We NEED HELP
> reproducing this.  Steps, hints, anything.  We are trying rebooting,
> suspending, opensuse, fedora, ubuntu, and several hardware platforms, etc.
>
> This seems to effect both 32 and 64 bit kernels, but we haven't heard much
> either way.
>
> hardware affected:
> laptops and desktops with 82566 or 82567 based LAN parts, which are
> machines with the ICH8 and ICH9 chipsets and a variety of processors.
> The machines I know of that have reported the issue include
> Lenovo X300
> HP 2510p
> Intel DP35JO
> Lenovo T61 (possibly)
> Lenovo X61 (possibly)
>
> Next steps:
> We are still trying to reproduce the issue locally, we should have a
> machine here tomorrow that reportedly had the issue with ubuntu.
>
> We have a series of kernel patches that I will reply to this mail with
> that may help users willing to test.
>
> We should have ready (hopefully tomorrow) an app that should be able to
> restore eeproms as long as the driver can still load.
>
> We also have a band-aid patch that should allow "locking" of the NVM area
> to prevent an errant write, we are looking to post that tomorrow.  This
> should prevent the damage but not really find the culprit.
>
> Jesse
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>
