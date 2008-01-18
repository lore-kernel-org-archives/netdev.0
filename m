From: "Glenn Griffin" <ggriffin.kernel@gmail.com>
Subject: ipv6 syn cookie questions
Date: Thu, 17 Jan 2008 18:06:18 -0800
Message-ID: <c9e534200801171806g23670a3eq37627bc875c2be59@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:38212 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757166AbYARCGU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2008 21:06:20 -0500
Received: by fg-out-1718.google.com with SMTP id e21so870763fga.17
        for <netdev@vger.kernel.org>; Thu, 17 Jan 2008 18:06:18 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In researching the linux implementation of syn cookies I stumbled on a few
points that aren't initially clear to me.  I was hoping somehow could elaborate
and shed some light onto what I'm missing.

at net/ipv6/tcp_ipv6.c:1249 within tcp_v6_conn_request()

There is the following comment:

        /*
         *      There are no SYN attacks on IPv6, yet...
         */

Also above that in the same file within tcp_v6_hnd_req() it looks like pieces
of an ipv6 syn cookie implementation were left but have been commented out.

I was not aware of ipv6 making any changes to how tcp behaved (ignoring obvious
details such as pseudo-header changes in checksum calculations, etc.), so the
comment above puzzles me.  How does ipv6 change the viability of syn attacks
against tcp?

Also if anyone can provide any background that may exist on an ipv6
implementation of syn cookies that would be appreciated.  I'm considering
working on an implementation, but would like to know if anyone is already
working on one or it's been submitted but deemed unnecessary for some reasons.

--Glenn
