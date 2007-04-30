From: Michael Kerrisk <mtk-manpages@gmx.net>
Subject: man-pages-2.45 and man-pages-2.46 are released
Date: Mon, 30 Apr 2007 08:31:15 +0200
Message-ID: <46358D33.9030709@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: lkml <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:33884 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1423079AbXD3Gba (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Apr 2007 02:31:30 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gidday,

I just released man-pages-2.45 and man-pages-2.46.

These releases are now available for download at:

    ftp://ftp.kernel.org/pub/linux/docs/manpages
    or mirrors: ftp://ftp.XX.kernel.org/pub/linux/docs/manpages

and soon at:

    ftp://ftp.win.tue.nl/pub/linux-local/manpages

These releases consist mainly of formatting fixes (to a large
number of pages) to achieve greater consistency across pages.

Currently there are a large number of fixes required to various man-pages.
   There are probably different people on these lists who would be able to
fix most of these; any assistance would be most appreciated.  A list of
some of the more significant problems is given below.

Cheers,

Michael



==========
man2/futex.2
     FIXME
     2.6.18 adds (Ingo Molnar) priority inheritance support:
     FUTEX_LOCK_PI, FUTEX_UNLOCK_PI, and FUTEX_TRYLOCK_PI.  These need
     to be documented in the manual page.  Probably there is sufficient
     material in the kernel source file Documentation/pi-futex.txt.

==========
man2/get_mempolicy.2
     FIXME writeme -- no errors are listed on this page

==========
man2/mount.2
     FIXME 2.6.15 added flags for "shared sub-tree" functionality:
     MS_UNBINDABLE, MS_PRIVATE, MS_SHARED, MS_SLAVE
     These need to be documented on this page.
     See Documentation/sharedsubtree.txt

==========
man2/quotactl.2
     FIXME There is much that is missing and/or out of date in this page.
     As things stand the page more or less documents Linux 2.2 reality:

==========
man2/set_mempolicy.2
     FIXME writeme -- no errors are listed on this page

==========
man2/shmop.2
     FIXME A good explanation of the rationale for the existence
     of SHMLBA would be useful here

==========
man4/initrd.4
     FIXME the manual page should describe the pivot_root mechanism.

==========
man5/acct.5
     FIXME this page needs to say a lot more, including mentioning
        Version 3 format process accounting on Linux.

==========
man5/core.5
     FIXME Is the following speculation correct?  If it is, then
     it might be worth incorporating it into the text:
     Always including the PID in the name of the core file made
     sense for LinuxThreads, where each thread had a unique PID,
     but doesn't seem to server any purpose with NPTL, where all the
     threads in a process share the same PID (as POSIX.1 requires).
     Probably the behaviour is maintained so that applications using
     LinuxThreads continue appending the PID (the kernel has no easy
     way of telling which threading implementation the userspace
     application is using). -- mtk, April 2006

==========
man5/locale.5
     FIXME glibc 2.2.2 added new non-standard locale categories:
     LC_ADDRESS, LC_IDENTIFICATION, LC_MEASUREMENT, LC_NAME,
     LC_PAPER, LC_TELEPHONE.  These need to be documented.

==========
man5/proc.5
     FIXME 2.6.14 has /proc/PID/numa_maps (if CONFIG_NUMA is
     enabled); this needs to be documented.
     Info on numa_maps can be found in the patch-2.6.14
     Changelog, but this is possibly not up to date.

     FIXME 2.6.13 seems to have /proc/vmcore implemented
     in the source code, but there is no option available under
     'make xconfig'; eventually this should be fixed, and then info
     from the patch-2.6.13 and change log could be used to write an
     entry in this man page.

     FIXME Describe /proc/[number]/loginuid
           Added in 2.6.11; updating requires CAP_AUDIT_CONTROL

     FIXME Describe /proc/[number]/mountstats and
           /proc/PID/task/TID/mountstats
          Some information can be found in the 2.6.17-rc1 change log.
           Added in 2.6.17

     FIXME Describe /proc/[number]/oom_adj
           Added in 2.6.11; updating requires CAP_SYS_RESOURCE
           Mention OOM_DISABLE (-17)
     FIXME Describe /proc/[number]/oom_score
           Added in 2.6.11; read-only

     FIXME Describe /proc/[number]/seccomp
           Added in 2.6.12

     FIXME Document /proc/config.gz (new in kernel 2.6)

     FIXME Actually, the following info abut the /proc/stat 'cpu' field
           does not seem to be quite right (at least in 2.6.12)

     FIXME more should be said about /proc/zoneinfo

==========
man7/capabilities.7
     FIXME CAP_KILL also has an effect for threads + setting child
           termination signal to other than SIGCHLD: without this
           capability, the termination signal reverts to SIGCHLD
           if the child does an exec().  What is the rationale
           for this?

     FIXME CAP_SETUID also an effect in exec(); document this.

     FIXME CAP_SYS_NICE also has the following effect for
     migrate_pages(2):
         do_migrate_pages(mm, &old, &new,
             capable(CAP_SYS_NICE) ? MPOL_MF_MOVE_ALL : MPOL_MF_MOVE);

==========
man7/ip.7
     FIXME has someone verified that 2.1 is really 1812 compliant?

     FIXME Document IP_FREEBIND

     FIXME document ip_autoconfig

     FIXME Document the conf/*/* sysctls
     FIXME Document the route/* sysctls
     FIXME document them all

     FIXME Add a discussion of multicasting

==========
man7/ipv6.7
     FIXME IPV6_CHECKSUM is not documented, and probably should be
     FIXME IPV6_JOIN_ANYCAST is not documented, and probably should be
     FIXME IPV6_LEAVE_ANYCAST is not documented, and probably should be
     FIXME IPV6_V6ONLY is not documented, and probably should be
     FIXME IPV6_RECVPKTINFO is not documented, and probably should be
     FIXME IPV6_2292PKTINFO is not documented, and probably should be
     FIXME there are probably many other IPV6_* socket options that
     should be documented

==========
man7/netlink.7
     FIXME More details on NETLINK_INET_DIAG needed.

     FIXME More details on NETLINK_XFRM needed.

     FIXME More details on NETLINK_ISCSI needed.

     FIXME More details on NETLINK_AUDIT needed.

     FIXME More details on NETLINK_FIB_LOOKUP needed.

     FIXME More details on NETLINK_NETFILTER needed.

     FIXME More details on NETLINK_KOBJECT_UEVENT needed.

     FIXME NLM_F_ATOMIC is not used any more?

     FIXME Explain more about nlmsg_seq and nlmsg_pid.


==========
man7/udp.7
     FIXME document UDP_ENCAP (new in kernel 2.5.67)


-- 
Michael Kerrisk
maintainer of Linux man pages Sections 2, 3, 4, 5, and 7

Want to help with man page maintenance?  Grab the latest tarball at
http://www.kernel.org/pub/linux/docs/manpages/
read the HOWTOHELP file and grep the source files for 'FIXME'.
