From: Hyong-Youb Kim <hykim@myri.com>
Subject: Re: [PATCH net-next] myri10ge: Add support for ndo_busy_poll
Date: Mon, 19 Aug 2013 05:20:57 -0700 (PDT)
Message-ID: <Pine.GSO.4.44.1308190431470.20676-100000@adel>
References: <1376902939-21968-1-git-send-email-hykim@myri.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-43-81-194.west.biz.rr.com ([24.43.81.194]:1908 "EHLO
	myri.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751336Ab3HSMVA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Aug 2013 08:21:00 -0400
In-Reply-To: <1376902939-21968-1-git-send-email-hykim@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Just for the record, here are a couple TCP_RR numbers from netperf.
Polling has the intended effect on this driver too.

Setup:
Linux 3.11-rc5 with many of unused features disabled
A couple machines with an E31270 CPU and a single-port 10G-PCIE-8B-S NIC
No switches
netperf 2.6.0
ethtool -C eth2 rx-usecs 0
ethtool -K eth2 gro off

net.core.busy_read=0: 53385.06 trans/s
net.core.busy_read=50: 87898.95 trans/s

The increase from busy_read is comparable to what Intel developers
reported earlier using ixgbe.
