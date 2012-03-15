From: chetan loke <loke.chetan@gmail.com>
Subject: time stamping packets (on Rx side)
Date: Thu, 15 Mar 2012 14:13:01 -0400
Message-ID: <CAAsGZS4OvqyRr-1vvTzW5+Lx5007tuwP5GsZHRDXEOY4q1Mw1A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:49415 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751408Ab2COSNC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Mar 2012 14:13:02 -0400
Received: by gghe5 with SMTP id e5so3342662ggh.19
        for <netdev@vger.kernel.org>; Thu, 15 Mar 2012 11:13:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

So with the (ptp clock support)PHC in place, some apps can use it as a
reference clock. But if I'm trying to debug/analyze packets(by TAP'ing
a link) using linux then I might still have a problem. Does Intel (or
any adapter with 1588 support) have the capability to time stamp the
packet on the NIC and not on the host side?  Because if we time stamp
on the host side then it all depends when we drain Port0 and Port1's
Rx descriptors of the dual-port NIC. It's quite possible that we might
see reply before request. But if the pkt was stamped by the NIC then
we know for sure which came first.

Chetan
