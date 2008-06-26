From: "Julius Volz" <juliusv@google.com>
Subject: Re: Sending big Netlink messages to userspace
Date: Thu, 26 Jun 2008 17:39:01 +0200
Message-ID: <f4845fc0806260839g45fa53e2w473684736e0cce56@mail.gmail.com>
References: <f4845fc0806240938h36d275ect109fd5f5414cba37@mail.gmail.com>
	 <4861282C.4000208@trash.net> <20080625104401.GJ20815@postel.suug.ch>
	 <20080625.155146.103043993.davem@davemloft.net>
	 <4862E5B0.9080007@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, tgraf@suug.ch,
	netdev@vger.kernel.org, vbusam@google.com
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:38422 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753253AbYFZPjJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2008 11:39:09 -0400
Received: from zps19.corp.google.com (zps19.corp.google.com [172.25.146.19])
	by smtp-out.google.com with ESMTP id m5QFd2mf006229
	for <netdev@vger.kernel.org>; Thu, 26 Jun 2008 16:39:03 +0100
Received: from wf-out-1314.google.com (wfc25.prod.google.com [10.142.3.25])
	by zps19.corp.google.com with ESMTP id m5QFcJPu019421
	for <netdev@vger.kernel.org>; Thu, 26 Jun 2008 08:39:02 -0700
Received: by wf-out-1314.google.com with SMTP id 25so65870wfc.6
        for <netdev@vger.kernel.org>; Thu, 26 Jun 2008 08:39:01 -0700 (PDT)
In-Reply-To: <4862E5B0.9080007@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 26, 2008 at 2:41 AM, Patrick McHardy <kaber@trash.net> wrote:
>> Therefore userland need never have a buffer larger than 8K or
>> sysconf(_SC_PAGESIZE), whichever is smaller.
>
> For dumps the size is fine, for large unicast messages it
> might need to be increased though (like nfnetlink_queue).

Ok, I put everything that is a list of variable size into dumps now.
One object (list entry) per multipart message (but several multipart
messages are sent in the same skb until it fills up).

All the other reply messages are of a fixed size and very small, so
fortunately I don't need to increase buffer sizes anywhere.

Julius

-- 
Google Switzerland GmbH
