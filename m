From: Stephen Hemminger <shemminger@osdl.org>
Subject: 2.6.12-rc4-tcp3
Date: Tue, 24 May 2005 16:39:39 -0700
Message-ID: <20050524163939.0fb86509@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262160AbVEXXjv@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

http://developer.osdl.org/shemminger/patches/2.6.12-rc4-tcp3

This is the third revision of the TCP pluggable congestion framework with
other network changes (targeted for 2.6.13)

Minor tweaks from last time:
	- startup changed because westwood and hybla 
	  need to do setup after initial connection establishment
	- initialization happens when socket is created (fixes bug with
	  auto module load and preempt).
	- module refcounting fix for passive opens
	- cleanup westwood and get rid of too much inlining
	- latest version of TSO patch included in set
	- fix min_cwnd undershoot bug for all but legacy reno

# Changes involving network core to remove throttling
fastroute-stats-remove
no-congestion
no-throttle
bigger-backlog
fix-weightp
# TSO fixes from dave
tcp_ack26
tcp_super_tso_v3
# TCP infrastructure
tcp_infra
tcp_bic
tcp_westwood
hstcp
hybla
vegas
h-tcp
# Makefile version
version
