From: Olaf Kirch <okir@suse.de>
Subject: Releasing new traceroute
Date: Mon, 1 Sep 2008 13:53:53 +0200
Message-ID: <200809011353.53449.okir@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.suse.de ([195.135.220.2]:34710 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751528AbYIALyG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Sep 2008 07:54:06 -0400
Received: from Relay2.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id AA57441C85
	for <netdev@vger.kernel.org>; Mon,  1 Sep 2008 13:54:03 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

a new version of my traceroute implementation is available from
ftp://ftp.lst.de/pub/people/okir/traceroute. I rewrote part
of the protocol handling to make it more flexible, and added
traceroute over TCP support. This uses the old-fashioned
listen-for-icmp-errors-on-raw-socket approach because we don't
have MSG_ERRQUEUE support in TCP, so it requires root privs.

Please give it a try and let me know whether you're seeing any
problems with it. One thing that's still missing is that over
IPv6, traceroute supports only UDP tracing, no ICMP or TCP.
That's mostly because I need to write the packet parsing code
that unwraps the IPv6 packet contained in the ICMP error
messages.

Cheers,
Olaf
-- 
 And mention in the Fitz incident that DCOP is no ego shooter!
                                --micha istinie, 2001
