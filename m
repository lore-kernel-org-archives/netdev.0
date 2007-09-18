From: "L F" <lfabio.linux@gmail.com>
Subject: Re: e1000 driver and samba
Date: Tue, 18 Sep 2007 12:32:09 -0400
Message-ID: <780b6f780709180932j5944b927p44ace42833e0230b@mail.gmail.com>
References: <780b6f780709171158h1016b6c2kfbc977b4ea7c715c@mail.gmail.com>
	 <36D9DB17C6DE9E40B059440DB8D95F5203592D77@orsmsx418.amr.corp.intel.com>
	 <20070918020358.d50653d5.billfink@mindspring.com>
	 <ygfps0g8lj0.fsf@janus.isnogud.escape.de> <82k5qoxfbk.fsf@mid.bfk.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Urs Thuermann" <urs@isnogud.escape.de>,
	"Bill Fink" <billfink@mindspring.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"James Chapman" <jchapman@katalix.com>, netdev@vger.kernel.org
To: "Florian Weimer" <fweimer@bfk.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.226]:18410 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758143AbXIRQcL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2007 12:32:11 -0400
Received: by nz-out-0506.google.com with SMTP id s18so1169489nze
        for <netdev@vger.kernel.org>; Tue, 18 Sep 2007 09:32:10 -0700 (PDT)
In-Reply-To: <82k5qoxfbk.fsf@mid.bfk.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is the latest ethtool -S :
beehive:~# ethtool -S eth4
NIC statistics:
     rx_packets: 33491526
     tx_packets: 41410384
     rx_bytes: 28384277429
     tx_bytes: 46178788616
     rx_broadcast: 3144
     tx_broadcast: 2068
     rx_multicast: 79
     tx_multicast: 0
     rx_errors: 0
     tx_errors: 0
     tx_dropped: 0
     multicast: 79
     collisions: 0
     rx_length_errors: 0
     rx_over_errors: 0
     rx_crc_errors: 0
     rx_frame_errors: 0
     rx_no_buffer_count: 0
     rx_missed_errors: 0
     tx_aborted_errors: 0
     tx_carrier_errors: 0
     tx_fifo_errors: 0
     tx_heartbeat_errors: 0
     tx_window_errors: 0
     tx_abort_late_coll: 0
     tx_deferred_ok: 36256
     tx_single_coll_ok: 0
     tx_multi_coll_ok: 0
     tx_timeout_count: 0
     tx_restart_queue: 0
     rx_long_length_errors: 0
     rx_short_length_errors: 0
     rx_align_errors: 0
     tx_tcp_seg_good: 0
     tx_tcp_seg_failed: 0
     rx_flow_control_xon: 37420
     rx_flow_control_xoff: 37420
     tx_flow_control_xon: 0
     tx_flow_control_xoff: 0
     rx_long_byte_count: 28384277429
     rx_csum_offload_good: 33478553
     rx_csum_offload_errors: 0
     rx_header_split: 0
     alloc_rx_buff_failed: 0
     tx_smbus: 0
     rx_smbus: 0
     dropped_smbus: 0
There have been no further deferred frames, in accordance to what was
posted above. However, as Urs very correctly points out, the problem
is still very much there. I am waiting for new and improved cables
(third batch) to see if that makes a difference.
I am also wondering if, perhaps, a layer3 managed switch with port
statistics may prove helpful.
To answer Bill's questions, memtest+ 1.70 was run overnight, it
totalled some fifty passes with no errors. I know that some maintain
that memtest is not a definitive RAM test, but it certainly catches
most problems.
As to the disk side of the equation, that is of course a possible
concern and I will be running a second, more intensive batch of tests.
However, the fact that virtualbox (running on the server) reports no
errors despite running through significant amounts of data (10GB+,
passing through samba via the tap device that is bridged to the
problematic ethernet) every day makes me fairly confident that the
disk side of the equation is not where the problem lies.

LF
