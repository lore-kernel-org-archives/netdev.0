From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: Protocol handler for Marvell DSA EtherType packets
Date: Fri, 01 Feb 2008 14:28:34 +0100
Message-ID: <1201872514.17661.50.camel@localhost.localdomain>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:36674 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754185AbYBANs3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2008 08:48:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Netdev

I writing a new protocol handler using dev_add_pack().  (For a Marvell
switch chip handling DSA (Distributed Switch Architecture) Ethertype
packets).

My protocol handler works and I get the skb. But I want to remove the
DSA Headers and send the packet back for normal processing on a
device. (I actually just want to be able to tcpdump these packets on
the device).

I'm removing the headers by:
  skb_pull(skb, sizeof(struct dsa_header));

I'm trying to retransmit it by:
  netif_rx(skb);

But it seems that I just retransmit the same packet without removing
the DSA headers.

Any hints about which functions I should use the remove the DSA header?

-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network developer
  Cand. Scient Datalog / MSc.
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer
