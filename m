From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [ANNOUNCE] iproute2 2.6.39
Date: Wed, 29 Jun 2011 16:27:22 -0700
Message-ID: <20110629162722.2db2a8cd@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58440 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751584Ab1F2X10 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2011 19:27:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This version of iproute2 utilities intended for use with 2.6.39 or
later kernel, but should be backward compatible with older releases.
It is mostly small bug fixes, but there is also support for the
new queuing disciplines in 2.6.39.

Source: (note old developer.osdl.org address works as well)
  http://devresources.linuxfoundation.org/dev/iproute2/download/iproute=
2-2.6.39.tar.gz

Repository:
  git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git

=46or more info on iproute2 see:
  http://www.linuxfoundation.org/collaborate/workgroups/networking/ipro=
ute2

Report problems (or enhancements) to the netdev@vger.kernel.org mailing=
 list.

Changelog:
Brandon Philips (2):
      ip: fix memory leak in ipmaddr.c
      doc: add pdf targets

Diego Elio Petten=F2 (1):
      Remove -L flags from link

Eric Dumazet (3):
      sfq: add divisor support
      ip: Support IFLA_TXQLEN in ip link command
      ss: fix autobound filter

Gerrit Renker (6):
      utils: get_jiffies always uses base=3D0
      iproute: fix unit conversion of rtt/rttvar/rto_min
      iproute: rename 'get_jiffies' since it uses msecs
      utils: get_jiffies always uses base=3D0
      iproute: fix unit conversion of rtt/rttvar/rto_min
      iproute: rename 'get_jiffies' since it uses msecs

Jiri Pirko (1):
      iplink: implement setting of master devic

John Fastabend (2):
      iproute2: tc add mqprio qdisc support
      iproute2: improve mqprio inputs for queue offsets and counts

Joy Latten (6):
      xfrm security context support
      xfrm security context support
      xfrm security context support
      xfrm security context support
      xfrm security context support
      xfrm security context support

Juliusz Chroboczek (1):
      tc : SFB flow scheduler

Nicolas Dichtel (3):
      iproute2: allow to specify truncation bits on auth algo
      iproute2: add support of flag XFRM_STATE_ALIGN4
      iproute2: allow to specify truncation bits on auth algo

Sridhar Samudrala (1):
      macvlan/macvtap: support 'passthru' mode

Stephen Hemminger (26):
      CHOKe scheduler
      Merge branch 'master' into choke
      update to net-next (2.6.39) headers
      Merge branch 'choke' into net-next
      Remove #ifdef's
      v2.6.38.1
      update to 2.6.39-rc3 headers
      Add no-strict-aliasing to genl
      Add checks for fgets() when reading proc
      Fix snprintf with non format
      Fix warning in u32 from assignment in conditional
      Update email address of netem
      Add README.devel
      Update README information
      Use INIT_NETDEV_GROUP
      Merge branch 'for-2.6.39' of /home/shemminger/iproute2-net-next
      tc filter: fix dport/sport in pretty print output
      ip: addrlabel fix set never used warning
      ip: iproute fix set never used warning
      tc: fix set never used warning in red
      libnetlink: fix set never used warning
      Fix set-never-used warning in ifstat
      ss: check result of readlink
      skbedit: fix set-never-used warning
      xt match: fix set-never-used warning
      v2.6.39

Ulrich Weber (1):
      iproute2: parse flag XFRM_POLICY_ICMP

Vlad Dogaru (6):
      iproute2: support listing devices by group
      iproute2: support device group semantics
      iproute2: support device group semantics
      iproute2: fix man page whitespace
      iproute2: fix man page whitespace
      iproute2: support listing devices by group

