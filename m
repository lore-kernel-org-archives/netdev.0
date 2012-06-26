From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] udp: Add socket early demux support
Date: Tue, 26 Jun 2012 22:49:07 +0200
Message-ID: <1340743747.10893.370.camel@edumazet-glaptop>
References: <1340739826-3363-1-git-send-email-subramanian.vijay@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, shemminger@vyatta.com,
	alexander.h.duyck@intel.com
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:62647 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751590Ab2FZUtO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 16:49:14 -0400
Received: by bkcji2 with SMTP id ji2so392093bkc.19
        for <netdev@vger.kernel.org>; Tue, 26 Jun 2012 13:49:12 -0700 (PDT)
In-Reply-To: <1340739826-3363-1-git-send-email-subramanian.vijay@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-06-26 at 12:43 -0700, Vijay Subramanian wrote:
> Based on the recent TCP socket early demux code, this patch provides similar
> support for UDP.
> 
> Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
> ---
> This has been tested on x86 with UDP iperf flows and seemed to work. If this is
> accepted, I plan to submit one more patch moving common code from TCP and UDP
> early demux code into common helper functions.
> Thanks in advance for feedback.

Hmm... I cant see how it can work.

Have you tested a router can still route DNS packets if you also have a
DNS server on it, listening on 0.0.0.0:53 ?

Most UDP applications are using unconnected sockets.
(In fact few programmers are aware UDP sockets can be connected)

Try to bench how this is going to work with random IP sources, instead
of UDP iperf flows using a single IP ?

And what about multicast ?
