From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 00/12] smaller iptunnel and ip6tunnel review
Date: Fri, 13 Nov 2015 18:08:53 +0100
Message-ID: <1447434545-32182-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:39365 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933387AbbKMRJI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2015 12:09:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In an effort to try and merge iptunnel and ip6tunnel support code, I found a
few things worth changing, mainly by comparing the two files.

Please note that I did not test functionality of all supported tunnel modes,
but since the changes are fairly small and obvious I hopefully didn't introduce
too many bugs.

Phil Sutter (12):
  ip{,6}tunnel: get rid of extraneous whitespace when printing
  ip/tunnel: introduce tnl_parse_key()
  ip{,6}tunnel: unify behaviour if physical device is not found
  iptunnel: use ll_name_to_index() for physical interface lookup
  ip{,6}tunnel: align do_tunnels_list() a bit
  ip6tunnel: print local/remote addresses like iptunnel does
  ip6tunnel: fix coding style: no newline between brace and else
  iptunnel: share common code when setting tunnel mode
  iptunnel: simplify parsing TTL, allow 'hlim' as identifier
  iptunnel: share common code when determining the default interface
    name
  iptunnel: sanitize copying tunnel name
  ip{,6}tunnel: put spaces around non-unary operators

 ip/ip6tunnel.c |  83 +++++++-------------
 ip/iptunnel.c  | 239 ++++++++++++++++++++++-----------------------------------
 ip/tunnel.c    |  15 ++++
 ip/tunnel.h    |   1 +
 4 files changed, 135 insertions(+), 203 deletions(-)

-- 
2.1.2
