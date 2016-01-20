From: Edward Cree <ecree@solarflare.com>
Subject: ethtool NFC/ntuple API questions
Date: Wed, 20 Jan 2016 17:10:53 +0000
Message-ID: <569FBF9D.40002@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:51712 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934332AbcATRLI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 12:11:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm looking into adding IPv6 support to the ethtool flow steering API.  But,
I don't know "the unfortunate history of and subtle differences between the
RX n-tuple versus RX NFC commands".  In particular, would I need to add IPv6
support to both of them, or only one?  If one would be sufficient, which one
is preferred?
Also, is it necessary to duplicate the profusion of variants that the IPv4
flow specs have (3x struct ethtool_tcpip4_spec, 2x struct
ethtool_ah_espip4_spec, and struct ethtool_usrip4_spec), or should I just
make one struct that contains all the fields from those (I would say "the
union of their fields", but that might be confusing), and rely on flow_type
to indicate which fields are meaningful?
And, what exactly are the hdata fields in ethtool_flow_union and the
anonymous union in ethtool_rx_ntuple_flow_spec (they're not documented) and
why are they different sizes?

-Ed
