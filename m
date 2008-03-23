From: carlos@fisica.ufpr.br (Carlos Carvalho)
Subject: why are there messages like assertion ((int)tcp_packets_in_flight(tp)...
Date: Sun, 23 Mar 2008 17:39:44 -0300
Message-ID: <18406.49168.311576.570515@fisica.ufpr.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fisica.ufpr.br ([200.17.209.129]:56992 "EHLO fisica.ufpr.br"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752560AbYCWUte (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Mar 2008 16:49:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We get these messages in the log from time to time:

assertion ((int)tcp_packets_in_flight(tp) >= 0) failed at net/ipv4/tcp_input.c (1274)

What do they mean? Is there a way to get rid of them? They usually
appear at high net traffic periods.

This is with a forcedeth chip, in case it's relevant.
