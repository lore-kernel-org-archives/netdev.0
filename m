From: Amar Mudrankit <amar.mudrankit@gmail.com>
Subject: Query about skb scatter / gather
Date: Fri, 6 Mar 2009 22:47:43 +0530
Message-ID: <c8028d330903060917r4af01c7ew2426bcb30af90b5e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.173]:23909 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752063AbZCFRRp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2009 12:17:45 -0500
Received: by wf-out-1314.google.com with SMTP id 28so637065wfa.4
        for <netdev@vger.kernel.org>; Fri, 06 Mar 2009 09:17:43 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Can I have a socket buffer received over network having protocol
headers (IP, TCP/UDP/ICMP) in first page of skb_frags_t array of the
skb?

So, in such a situation the skb->data is almost 0 and all the data
along with headers is in pages listed in skb_frags_t array.

Can linux networking stack handle such socket buffer? Or is it
mandatory that, at least some minimum data should be accessible
through skb->data and rest can be in pages described in skb_frags_t
array?

Also can anyone suggest good pointers for making use of frag_list in
skb_shared_info structure? Is it meant to represent one network packet
as the list of multiple skbs each skb holding part of packet data in
the order they are linked?

I tried finding it in UNDERSTANDING LINUX NETWORK INTERNALS by
CHRISTIAN BENVENUTI, but couldn't find anything conclusive.  As I
understand, it is enabled through NETIF_F_FRAGLIST feature of the
device.

Thanks in Advance.

Regards,
Amar
