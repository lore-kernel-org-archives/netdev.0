From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netns: oops in ip_frag_reasm incrementing stats
Date: Fri, 13 Mar 2009 11:46:16 -0700 (PDT)
Message-ID: <20090313.114616.71504422.davem@davemloft.net>
References: <49BA87F4.1090709@dti2.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jorge@dti2.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38873
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754526AbZCMSqa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 14:46:30 -0400
In-Reply-To: <49BA87F4.1090709@dti2.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
Date: Fri, 13 Mar 2009 17:21:08 +0100

> skb->dev can be NULL on ip_frag_reasm for skb's coming from RAW sockets.
> 
> Quagga's OSPFD sends fragmented packets on a RAW socket, when netfilter
> conntrack reassembles them on the OUTPUT path you hit this code path.
> 
> Signed-off-by: Jorge Boncompte [DTI2] <jorge@dti2.net>

Your patch was corrupted by your email client, please fix this up and
resubmit.
