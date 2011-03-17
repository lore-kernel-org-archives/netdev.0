From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [ANNOUNCE] iproute 2.6.38
Date: Thu, 17 Mar 2011 10:16:52 -0700
Message-ID: <20110317101652.27e68348@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36931 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751846Ab1CQRQz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Mar 2011 13:16:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Due to popular demand, there is an iproute2 release for 2.6.38 after all. 

This version of iproute2 utilities intended for use with 2.6.38 or
later kernel, but should be backward compatible with older releases.
New features are support for macvlan passthru and xfrm security context.

Source: (note old developer.osdl.org address works as well)
  http://devresources.linuxfoundation.org/dev/iproute2/download/iproute2-2.6.38.tar.bz2

Repository:
  git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git

For more info on iproute2 see:
  http://www.linuxfoundation.org/collaborate/workgroups/networking/iproute2

Report problems (or enhancements) to the netdev@vger.kernel.org mailing list.

Changelog:

Gerrit Renker (3):
      utils: get_jiffies always uses base=0
      iproute: fix unit conversion of rtt/rttvar/rto_min
      iproute: rename 'get_jiffies' since it uses msecs

Joy Latten (3):
      xfrm security context support
      xfrm security context support
      xfrm security context support

Nicolas Dichtel (1):
      iproute2: allow to specify truncation bits on auth algo

Sridhar Samudrala (1):
      macvlan/macvtap: support 'passthru' mode

Stephen Hemminger (2):
      Update to lasest kernel headers
      v2.6.38.1

Vlad Dogaru (1):
      iproute2: fix man page whitespace

