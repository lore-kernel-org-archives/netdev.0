From: Alan Stern <stern@rowland.harvard.edu>
Subject: Questions regarding local address assignment
Date: Mon, 14 Apr 2008 11:19:56 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.0804141115300.2528-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from iolanthe.rowland.org ([192.131.102.54]:54046 "HELO
	iolanthe.rowland.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1760689AbYDNPT5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 11:19:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Suppose a program creates a socket and doesn't bind it to a local 
address.  When the program wants to connect the socket to a remote 
address (for TCP) or send a datagram to a remote address (for UDP or 
raw IP), the kernel automatically assigns a local address to it.

Questions:

	1. What algorithm does the kernel use to select the local 
	   address?

	2. Where is the source code for the selection?

	3. Is this information documented anywhere?

Thank you,

Alan Stern

