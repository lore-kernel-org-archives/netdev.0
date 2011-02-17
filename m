From: Matt Domsch <Matt_Domsch@Dell.com>
Subject: biosdevname v0.3.7
Date: Thu, 17 Feb 2011 10:15:40 -0600
Message-ID: <20110217161540.GA29554@auslistsprd01.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-hotplug@vger.kernel.org, netdev@vger.kernel.org,
	"K, Narendra" <Narendra_K@Dell.com>,
	"Hargrave, Jordan" <Jordan_Hargrave@Dell.com>,
	"Rose, Charles" <Charles_Rose@Dell.com>,
	Co
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

biosdevname, now version 0.3.7.

Major visible changes include no longer using '#' in device names (by
popular demand), no longer suggesting new names if running inside a VM
guest (tested with KVM, SLES 10 Xen, XenServer, VMware ESX, but it
uses the generic cpuid test, so should work on most virt platforms),
and a new kernel command line option 'biosdevname={0|1}' which udev
honors, to force enabling or disabling of invoking biosdevname.

Still to come: NPAR partition->port mapping support (initially
Dell-specific, but if NIC vendors have other ways to expose this,
please let me know).


Grab it here:
http://linux.dell.com/files/biosdevname/permalink/biosdevname-0.3.7.tar.gz
http://linux.dell.com/files/biosdevname/permalink/biosdevname-0.3.7.tar.gz.sign
git://linux.dell.com/biosdevname.git

I built this today for Fedora rawhide and F15, and I encourage
other distributions to pick it up as well.

shortlog:

Andrew Cooper (3):
      Fix segfault when BIOS advertises zero sized PIRQ Routing Table
      Add 'bonding' and 'openvswitch' to the virtual devices list
      Typo fixes

Harald Hoyer (1):
      Add kernel command line parameter "biosdevname={0|1}" to turn off/on

Matt Domsch (7):
      don't build or package dump_pirq, use biosdecode from dmidecode instead
      don't use '#' in names, use 'p' instead, by popular demand
      properly look for SMBIOS, then $PIR, then recurse
      update changelog
      Fix test for PIRQ table version
      fail PIRQ lookups if device domain is not 0
      exit(4) if running a virtual machine

Thanks,
Matt

-- 
Matt Domsch
Technology Strategist
Dell | Office of the CTO
