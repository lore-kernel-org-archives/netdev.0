From: "Paul Marks" <paul@pmarks.net>
Subject: When should kfree_skb be used?
Date: Thu, 8 May 2008 21:49:27 -0700
Message-ID: <8e5b27790805082149y6d9f604ds7feefe2804f3823c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.29]:8711 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753616AbYEIEtj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2008 00:49:39 -0400
Received: by yw-out-2324.google.com with SMTP id 9so629595ywe.1
        for <netdev@vger.kernel.org>; Thu, 08 May 2008 21:49:27 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, I'm trying to make sense of the ipip6_rcv function here:

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=blob;f=net/ipv6/sit.c;hb=HEAD#l564

Specifically, why is kfree_skb called when pskb_may_pull(...) returns
true, but not called when it returns false?  Is there something in the
code path which increments the skb's reference count that I'm not
noticing?
