From: "Ritesh Kumar" <ritesh@cs.unc.edu>
Subject: accessing TCP port numbers of an skb in a qdisc
Date: Wed, 11 Apr 2007 00:33:45 -0400
Message-ID: <f47983b00704102133o65ba670br4ff00c4f19e115a0@mail.gmail.com>
References: <f47983b00704102131q3787f294pa15b3006f7ce8ade@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.233]:40264 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161187AbXDKEdq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Apr 2007 00:33:46 -0400
Received: by wr-out-0506.google.com with SMTP id 71so45168wri
        for <netdev@vger.kernel.org>; Tue, 10 Apr 2007 21:33:46 -0700 (PDT)
In-Reply-To: <f47983b00704102131q3787f294pa15b3006f7ce8ade@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
    For some per-flow queue management work I need to access TCP port
numbers of an skb inside a qdisc (i.e. in qdisc enqueue and dequeue
functions). Can I assume that skb->data always points to the head of
the IP header of the packet? If that is the case will the following
statements do the trick?

if(skb->nh.iph->protocol == IPPROTO_TCP) {
    skb->h.raw = skb->data + (skb->nh.iph->ihl*4);
    /* read the tcp port numbers in
     * skb->h.th->source and skb->h.th->dest
     */
}

Thanks a lot for your help!

Ritesh
