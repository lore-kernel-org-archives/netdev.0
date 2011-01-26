From: Matt Domsch <Matt_Domsch@Dell.com>
Subject: biosdevname v0.3.6
Date: Wed, 26 Jan 2011 13:18:09 -0600
Message-ID: <20110126191809.GA15585@auslistsprd01.us.dell.com>
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

biosdevname, now version 0.3.6.

(0.3.5 was a dud due to a change in gcc/libtool that broke building
 the static copy.  https://bugzilla.redhat.com/show_bug.cgi?id=672689)

this fixes the udev rules, such that biosdevname is not invoked if an
earlier rule (such as 70-persistent-net.rules) sets a name.  this has
been the intended behavior, but was missed until now.  
furthermore, /usr/sbin/dump_pirq was added as a debugging aid, the
static copy biosdevnames is no longer built (it was originally
intended for use inside fairly limited initrd environments, but was
never really used there, and with dracut is now unnecessary),
and it checks if you're running as root, as it needs root to read
SMBIOS and PCI IRQ Routing Table information.

Grab it here:
http://linux.dell.com/files/biosdevname/permalink/biosdevname-0.3.6.tar.gz
http://linux.dell.com/files/biosdevname/permalink/biosdevname-0.3.6.tar.gz.sign
git://linux.dell.com/biosdevname.git

I built this yesterday for Fedora rawhide (will be 15), and I encourage
other distributions to pick it up as well.

There is a Fedora Test Day tomorrow (Thursday)
  https://fedoraproject.org/wiki/Test_Day:2011-01-27_Network_Device_Naming_With_Biosdevname
and I encourage you to give this a try and report success/failures as
noted here.

There has also been a good bit of blog coverage over the last few
days, with thanks to Joe Brockmeier.  
  http://www.networkworld.com/community/fedora-15-changes-network-device-naming



shortlog:

Matt Domsch (13):
      add check for running as root, exit if not
      add exit code 3 to manpage
      udev rules: skip if NAME is already set
      build dump_pirq, minimizing library linking
      install dump_pirq into /usr/sbin/
      install dump_pirq in debs too
      update changelogs, bump version
      move udev rules file into /lib/udev/rules.d
      update changelog
      add TODO
      automatically determine which dir the rules file goes
      drop biosdevnameS, it's unused and fails to build on F15
      bump version


Thanks,
Matt

-- 
Matt Domsch
Technology Strategist
Dell | Office of the CTO
