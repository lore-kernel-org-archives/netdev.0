From: Susant Sahani <ssahani@gmail.com>
Subject: NF_STOLEN and reinsert in to IP stack
Date: Sat, 30 Jan 2010 14:27:18 +0530
Message-ID: <d81115a61001300057m37670c2bq45b740ec0a2aa34@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netfilter-devel@lists.netfilter.org, netfilter@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f182.google.com ([209.85.216.182]:46782 "EHLO
	mail-px0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750977Ab0A3JFA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jan 2010 04:05:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have yet to find any resource that answers this question.  If I have
a kernel module that registers a callback with netfilter and steals a
packet during the NF_IP_PRE_ROUTING stage, How can I re-insert this

packet on the network stack, (before the ip routing stage) so it is
forwarded back out on the correct device?

susant

Charles de Gaulle  - "The better I get to know men, the more I find
myself loving dogs." -
http://www.brainyquote.com/quotes/authors/c/charles_de_gaulle.html
