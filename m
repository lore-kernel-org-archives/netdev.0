From: Duc Thinh Le <ducthinhle@yahoo.ca>
Subject: TCP fragmentation on IPv6
Date: Mon, 28 Jan 2013 14:21:14 -0800 (PST)
Message-ID: <1359411674.12755.YahooMailClassic@web125405.mail.ne1.yahoo.com>
References: <1359411606.93934.YahooMailClassic@web125402.mail.ne1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm4-vm1.bullet.mail.ne1.yahoo.com ([98.138.91.44]:46053 "EHLO
	nm4-vm1.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755093Ab3A1W06 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2013 17:26:58 -0500
In-Reply-To: <1359411606.93934.YahooMailClassic@web125402.mail.ne1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello TCP experts,

  I am sorry to bother you. But I am just wondering if
  you can shed some light on how TCP-v6 (Linux - Fedora)
  handle the case where it send a segment of 1500 bytes
  and then some router along the way sends back the
  ICMPv6 "too big - 1300" message. There are two choices:

     1) TCPv6 resends the original segment (1500) into
        two new TCP segments (one with 1300) and the other
        is 200.

        OR

     2) TCPv6 sends out two IPv6 fragment packets to
        achieve the original 1500

    OR maybe, there are other ways as well. Thanks for your
  times and helps. If there is a another forum that I can ask these
  kinds of questions, please let me know. Thanks a lot.

Regards
Duc Le
