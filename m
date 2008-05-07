From: "prodyut hazarika" <prodyuth@gmail.com>
Subject: Re: State of TCP segmentation offload to NIC in linux
Date: Wed, 7 May 2008 14:26:50 -0700
Message-ID: <49c0ff980805071426h54073ddcw89ebe37a3d4e95b4@mail.gmail.com>
References: <49c0ff980805011056q25d24616vf4cea6d8b387b717@mail.gmail.com>
	 <D5C1322C3E673F459512FB59E0DDC3290501C9EA@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.239]:36254 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753321AbYEGV0x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2008 17:26:53 -0400
Received: by wr-out-0506.google.com with SMTP id c48so269833wra.1
        for <netdev@vger.kernel.org>; Wed, 07 May 2008 14:26:50 -0700 (PDT)
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC3290501C9EA@orsmsx414.amr.corp.intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for your reply, Peter. I would appreciate if you could clarify
little more.


> The IP layer does not need to be bypassed.  The TCP layer will set the
> proper headers for TSO to work properly and continue sending the skb
> down the stack.  IP will not fragment a packet on transmit.

Which flag/header does the TCP layer set to indicate to IP that it
should not fragment a 64K segment, but rather offload the whole
segment to NIC? I tried to look at the TCP code in linux stack, but
could not figure the flag or the logic that sets the flag/header you
mentioned. The NIC driver must indicate that it is capable of doing
TSO by setting NETIF_F_TSO flag, but NETIF_F_TSO capability is not
checked in IP/TCP layer.

I would really appreciate if you could point me to the function in TCP
code in linux.

Thanks for your time,
Prodyut
