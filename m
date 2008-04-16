From: Bruce Allen <ballen@gravity.phys.uwm.edu>
Subject: (unknown)
Date: Wed, 16 Apr 2008 04:38:44 -0500 (CDT)
Message-ID: <Pine.LNX.4.63.0804160434190.8267@trinity.phys.uwm.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Bruce Allen <bruce.allen@aei.mpg.de>,
	Carsten Aulbert <carsten.aulbert@aei.mpg.de>,
	Henning Fehrmann <henning.fehrmann@aei.mpg.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from trinity.phys.uwm.edu ([129.89.57.159]:59981 "EHLO
	trinity.phys.uwm.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756606AbYDPKOU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2008 06:14:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Netdev,

We're doing some HPC Linpack testing on cluster nodes with the e1000 
driver. Sometimes the networking appears to 'hang'. The switches have 
their egress buffers full, but it seems as if the compute nodes are not 
accepting any more traffic.  (Yes, pause RX is off.)

We notice that rx_no_buffer_count and rx_missed_errors sometimes have high 
counts.  Could somebody explain to us what this means?  Any suggestions 
for improving matters?

Cheers,
 	Bruce
