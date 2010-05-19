From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [ANNOUNCE] iproute2 2.6.34
Date: Wed, 19 May 2010 08:54:53 -0700
Message-ID: <20100519085453.77d56521@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-net@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54462 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753722Ab0ESPy6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 May 2010 11:54:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This version of iproute2 utilities intended for use with 2.6.34 or
later kernel, but should be backward compatible with older releases.
In addition to build and man page fixes, this release includes a
support for several new features:

   * SR-IOV (I/O Virtualization) support.
   * tuntap support
   * bus-error reporting and counters
   * new FIFO type head drop queue discipline

The tar ball is available at:
  http://devresources.linuxfoundation.org/dev/iproute2/download

Repository:
  git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git

=46or more info on iproute2 see:
  http://www.linuxfoundation.org/collaborate/workgroups/networking/ipro=
ute2

Report problems (or enhancements) to the netdev@vger.kernel.org mailing=
 list.

Changes since last release (2.6.33)

Alexandre Cassen (1):
      Detect 6rd kernel missing support / 6rd tunnel scope

Andreas Henriksson (2):
      iproute2: detect iptables modules dir in configure.
      iproute2: add option to build m_xt as a tc module (v3)

Bart Trojanowski (1):
      fix build issues with flex ver 2.5

Brian Bloniarz (1):
      ip: document initcwnd

Chris Wright (1):
      iproute2: rework SR-IOV VF support

David Woodhouse (1):
      Add 'ip tuntap' support.

=46lorian Westphal (1):
      iproute2: fix addrlabel interface names handling

Hagen Paul Pfeifer (1):
      tc: add new queue discipline: head drop fifo

Jamal Hadi Salim (3):
      xfrm: policy by mark
      xfrm: Introduce xfrm by mark
      xfrm: add support for SA by mark

Jan Engelhardt (1):
      ip: correctly report tunnel link type

Michele Petrazzo - Unipex (1):
      Continue after errors in -batch

Williams, Mitch A (3):
      Update man page to indicate current options
      ip: Add support for setting and showing SR-IOV virtual funtion li=
nk params
      libnetlink: Modify the parser to track first duplicated attribute=
s

Wolfgang Grandegger (1):
      iproute2: netlink support for bus-error reporting and counters

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E (1):
      gaiconf: /etc/gai.conf configuration helper.

jamal (1):
      skbedit: use get_u32 for parsing mark

laurent chavey (1):
      Add initcwnd to iproute2

Stephen Hemminger:
      Fix line numbering on batch commands
      Remove mirred debug message
      Workaround missing ALIGN() macro.
      Update ip.8 man page to describe route table id values
      Update kernel headers to 2.6.34 final version
      Add documentation for ip link add/delete sub-commands
      ip: add documentation for initrwnd
      v2.6.34
