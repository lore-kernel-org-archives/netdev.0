From: Vince Laviano <vlaviano@cisco.com>
Subject: IGMPv3 for Linux
Date: Mon, 15 Jul 2002 17:39:19 -0700 (PDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <34825.6491394297$1026782037@news.gmane.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <kuznet@ms2.inr.ac.ru>, <linux-net@vger.kernel.org>, <netdev@oss.sgi.com>,
   <wilbert@kloosterhof.com>, <eckert@cisco.com>
Return-path: <owner-netdev@oss.sgi.com>
To: <davem@redhat.com>
List-Id: netdev.vger.kernel.org


Hi everyone,

I've been working on a port of Wilbert de Graaf's (wilbert@kloosterhof.com)
IGMPv3 implementation for FreeBSD to Linux 2.4.x.

A tarball containing the patch (against Linux 2.4.6), documentation, and some
test programs demonstrating use of the new multicast source filter (MSF) API
is available at ftp://ftpeng.cisco.com/igmpv3linux/igmpv3linux-v0003.tar.gz

This is alpha quality software, and there is still a good amount of work to be
done, but it's reached a stage where some people may find it useful.  Also, I'm
anxious to receive feedback on both the high-level approach and on any specific
problems that people detect.

Known limitations are:
    - ip_mc_destroy_dev() not yet implemented
    - probable concurrency issues
    - Only traditional struct ip_mreq accepted by MSF API functions; no
      support for struct ip_mreqn (i.e. identification of join interface by
      ifindex).
    - ip_mc_inc_group() and ip_mc_dec_group() internal interface used by GRE
      not yet implemented.
    - Source filters not used for raw socket delivery, only for UDP delivery
    - Coarse-grained locking
    - Protocol-independent MSF API not implemented

The web page for the original FreeBSD implementation is in the middle of being
migrated to http://www.kloosterhof.com/~wilbert/igmpv3.html.  For now, a Google-
cached copy can be viewed at http://www.google.com/search?q=cache:w5LFEFJjCugC:home.hetnet.nl/~wilbertdg/igmpv3.html+igmpv3&hl=en&ie=UTF-8

Thanks,
Vince Laviano
vlaviano@cisco.com
