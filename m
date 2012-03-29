From: Avleen Vig <avleen@gmail.com>
Subject: Crash in __netif_receive_skb
Date: Wed, 28 Mar 2012 20:31:16 -0500
Message-ID: <CAMjP1Kka6MmT2zLc95ZQ=vigS6w9diS9-tawzdUdhbzzfzMh3w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:32904 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758027Ab2C2BbS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2012 21:31:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi folks, someone in #kernel recommended I email these two lists. Hope
they're the right place.

We're running 2.6.32-220.4.1.el6.x86_64 on Centos 6.2, and getting a
repeated crash:
    https://gist.github.com/2231998

We can make this happen pretty easily just by passing some network
traffic and waiting a while.
I couldn't find any references to this particular issue.
I have vmcore files and am happy to dig into it if it would help (as
long as someone can tell me what to do :))

Help?
