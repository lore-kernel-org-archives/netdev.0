From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [ANNOUNCE] iproute2 2.6.37
Date: Fri, 7 Jan 2011 10:24:48 -0800
Message-ID: <20110107102448.2470638e@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org, linux-net@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:53048 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755192Ab1AGSYx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jan 2011 13:24:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This version of iproute2 utilities intended for use with 2.6.37 or
later kernel, but should be backward compatible with older releases.
Most of the changes are minor cleanups and fixes; new features
are:
   * support for flow matching based on rxhash
   * checksum update action

Source: (note old developer.osdl.org address works as well)
  http://devresources.linuxfoundation.org/dev/iproute2/download/iproute=
2-2.6.37.tar.bz2

Repository:
  git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git

=46or more info on iproute2 see:
  http://www.linuxfoundation.org/collaborate/workgroups/networking/ipro=
ute2

Report problems (or enhancements) to the netdev@vger.kernel.org mailing=
 list.

Andreas Schwab (1):
      iproute2: remove useless use of buffer

Ben Greear (2):
      iproute2: Fix filtering related to flushing IP addresses.
      Allow 'ip addr flush' to loop more than 10 times

Changli Gao (1):
      iproute2: tc: f_flow: add key rxhash

Dan Smith (1):
      Add ip route save/restore

Eric Dumazet (2):
      ip: add RTA_MARK support
      iproute2: add 64bit support to ifstat

Gerrit Renker (1):
      tc-red: typo in man page

Gregoire Baron (1):
      tc: add ACT_CSUM action support (csum)

Mike Frysinger (1):
      m_xt: stop using xtables_set_revision()

Octavian Purdila (1):
      iproute2: initialize the ll_map only once

Petr Sabata (3):
      ss(8) improvements by Jiri Popelka <jpopelka@redhat.com>
      ss: Change "do now" to "do not" in ss(8), -n option
      ip: Few typo and grammar errors fixes for ip(8) manpage

Sridhar Samudrala (1):
      Support 'mode' parameter when creating macvtap device

Stephen Hemminger (11):
      Snapshot for 2.6.35.1
      Update kernel headers to 2.6.36-rc2
      Use correct rt_link_statistics
      Fix GRED options clearing
      Update to 2.6.36 headers
      Workaround for repeated distclean
      Use standard routines for interface name to index etc
      Increase size of ifindex hash heads
      Cleanup ll_map
      Update to 2.6.37-rc8 headers
      v2.6.37

Timo Ter=E4s (2):
      iproute2: treat gre key as number
      iproute2: support xfrm upper protocol gre key

Ulrich Weber (2):
      iproute2: dont filter cached routes on iproute_get
      iproute2: display xfrm socket policy direction

