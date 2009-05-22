From: mopsosforum <mopsosforum@gmail.com>
Subject: using the igmph structure with skb : error in value
Date: Fri, 22 May 2009 13:19:05 +0100
Message-ID: <74FCA40A-033B-48A0-B9B5-4700AAC1D4E2@gmail.com>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.240]:42551 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754643AbZEVMTK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2009 08:19:10 -0400
Received: by an-out-0708.google.com with SMTP id d40so3531362and.1
        for <netdev@vger.kernel.org>; Fri, 22 May 2009 05:19:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I work on a kernel 2.6.21 with ebtables.

I develop a module for ebtables, and I need to analyse the igmp header.

I have this function (just to see the value)

static int ebt_target (struct sk_buff           **pskb,
                        unsigned int             hooknr,
                        const struct net_device  *in,
                        const struct net_device  *out,
                        const void               *data,
                        unsigned int             datalen)

{
struct sk_buff          *skb = *pskb;
printk ("igmp type :%u\n", skb->h.igmph->type);

}

I send a igmp packet to join a group
and I recieve this

       igmp type : 70

Normaly the good value in my case is  22 (I worked with igmp v3).

I don't undestand the response?

Then I try to see the ip of the multicast group (I send for the group
239.255.1.4) , I recieve 0.0.24.0 .

It's really strange because if I try to see the ip address of the
packet, it's works  (skb->h.ipiph->daddr) : 224.0.0.22


