From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 3278] New: Missing include statements
Date: Thu, 26 Aug 2004 13:45:43 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040826134543.344f5c9d.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Thu, 26 Aug 2004 05:55:52 -0700
From: bugme-daemon@osdl.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 3278] New: Missing include statements


http://bugme.osdl.org/show_bug.cgi?id=3278

           Summary: Missing include statements
    Kernel Version: 2.6.9-rc1
            Status: NEW
          Severity: normal
             Owner: laforge@gnumonks.org
         Submitter: brix@gimp.org


Distribution: Gentoo Linux

Hardware Environment: IBM ThinkPad X31

Software Environment:
Linux sponge 2.6.8.1 #7 Wed Aug 25 22:37:20 CEST 2004 i686 Intel(R) Pentium(R) M
processor 1300MHz GenuineIntel GNU/Linux

Gnu C                  3.3.3
Gnu make               3.80
binutils               2.14.90.0.8
util-linux             2.12
mount                  2.12
module-init-tools      3.0
e2fsprogs              1.35
pcmcia-cs              3.2.5
PPP                    2.4.1
nfs-utils              1.0.6
Linux C Library        2.3.3
Dynamic linker (ldd)   2.3.3
Procps                 3.1.15
Net-tools              1.60
Kbd                    1.12
Sh-utils               5.2.1
Modules Loaded         arc4 ieee80211_crypt_wep crc32 usbhid eth1394 ds ipw2100
firmware_class ieee80211 ieee80211_crypt ohci1394 ieee1394 yenta_socket
pcmcia_core snd_intel8x0m snd_intel8x0 snd_ac97_codec snd_mpu401_uart
snd_rawmidi snd_pcm_oss snd_pcm snd_page_alloc snd_timer snd_mixer_oss snd
soundcore ibm_acpi

Problem Description:

The following files, perhaps more, should #include <linux/netfilter_ipv4.h> or
symbols like NF_IP_PRE_ROUTING will be unknown.

  net/ipv4/netfilter/ip_conntrack_proto_tcp.c
  net/ipv4/netfilter/ip_conntrack_proto_udp.c
  net/ipv4/netfilter/ip_conntrack_proto_icmp.c


Steps to reproduce: Enable netfilter connection tracking and compile.

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
