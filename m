From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: New version 0.4.0 of the Linux Container
Date: Wed, 29 Oct 2008 00:10:00 +0100
Message-ID: <49079BC8.6020106@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Containers <containers@lists.osdl.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:53246 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753290AbYJ1XK5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 19:10:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The version 0.4.0 of the Linux Containers userspace tools has been released.

It is available at:

https://sourceforge.net/projects/lxc/

This version provides:

  * the lxc commands can be used as a non-root user, that allows a 
container to be ran without root privileges. This feature relies on the 
file capabilities, without them the lxc commands should be run as the 
root user

  * the monitoring has been improved, so several readers can monitor the 
same container state changes. The command line lxc-monitor can work with 
regexp, so it is easy to specify several containers with a simple 
regexp, or an extended regexp.

ChangeLog between this version and the previous version:

2008-10-28 23:08  dlezcano

	* Makefile.am: Generate a ChangeLog, if possible, and copy it to
	  the dist directory in order to be shipped with the release

2008-10-28 23:06  dlezcano

	* release.sh: Added a helper to generate the Changelog between two
	  releases

2008-10-26 23:06  dlezcano

	* Makefile.am, configure.in, lxc.spec.in, src/lxc/Makefile.am,
	  src/lxc/lxc.h: Fixed different compilation scheme by making
	  /var/lxc directory relative to the installation prefix and by
	  adding some extra path to search for the 'setcap' command.

2008-10-25 00:08  dlezcano

	* Makefile.am, configure.in: Added automatic generation of packages
	  and repository tagging

2008-10-25 00:06  dlezcano

	* ChangeLog: Automatically generated now with cvs2cl command

2008-10-24 23:56  dlezcano

	* release.sh: Helper script to generate releases

2008-10-24 23:33  dlezcano

	* ChangeLog: Version lxc-0.4.0

2008-10-24 22:24  dlezcano

	* lxc.spec.in, src/lxc/Makefile.am: Added file capabilities to
	  lxc-restart

2008-10-24 22:14  dlezcano

	* configure.in, lxc.spec.in, src/lxc/Makefile.am,
	  src/lxc/destroy.c: Give the ability to non-root user to play with
	  the containers. This feature relies on the file capabilities,
	  when the lxc commands are installed, the sys/net admin
	  capabilities are given to these files. These capabilities are not
	  available for the application running inside the container.

2008-10-24 22:11  dlezcano

	* src/lxc/execute.c: Exit instead of returning in the child
	  processes, otherwise the execution path of the child will be
	  wrong in case of error.

2008-10-23 15:09  legoater

	* src/lxc/restart.c: removed opentty now useless and fixed pid of
	  root process for restart

2008-10-23 09:21  legoater

	* configure.in: fix missing src/lxc/lxc-checkconfig

2008-10-20 13:45  dlezcano

	* src/lxc/: Makefile.am, lxc-checkconfig.in: This new command is a
	  helper to check if the needed functionalities are compiled the
	  kernel. It relies on /proc/config.gz, if it is not compiled, the
	  command will simply fail.  If a feature is missing but not
	  mandatory, "disabled" keyword will appear in yellow, if it is
	  mandatory, it will appear in "red", otherwise the key word
	  "enabled" will appear in green.

2008-10-18 23:07  dlezcano

	* src/lxc/: destroy.c, lxc.h, lxc_monitor.c, lxc_wait.c, monitor.c,
	  monitor.h: These modifications improve the monitoring support of
	  the container. Now several readers can attend the events from one
	  or several containers.  The syntax of the command has been
	  enhanced to interpret regular expressions.  If you want to
	  monitor foo, lxc-monitor -n foo is the right command. If you want
	  to monitor foo and bar, you should specify lxc-monitor -n
	  "foo|bar", if you want to monitor all containers with the name
	  beginning with 'foo', you have to specify lxc-monitor -n "foo.*".
	  More complex regexp can be specified in accordance with the POSIX
	  definitions, man regex (7).

2008-10-15 09:30  dlezcano

	* README: Updated with the cgroup section and fixed some typos


