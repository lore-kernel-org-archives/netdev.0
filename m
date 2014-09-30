From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: How exactly does CHECKSUM_COMPLETE works?
Date: Tue, 30 Sep 2014 12:22:57 -0700
Message-ID: <1412104977.30721.94.camel@edumazet-glaptop2.roam.corp.google.com>
References: <B5657A6538887040AD3A81F1008BEC63B41317@avmb3.qlogic.org>
	 <CA+mtBx_17aJuK=xjnDukGJOfw-twHg=rF5rDacg6pga6ZTTRcw@mail.gmail.com>
	 <B5657A6538887040AD3A81F1008BEC63B4152D@avmb3.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Tom Herbert (Partner - google)" <therbert@google.com>,
	netdev <netdev@vger.kernel.org>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:45950 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751436AbaI3TW6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 15:22:58 -0400
Received: by mail-pd0-f180.google.com with SMTP id fp1so5709789pdb.11
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2014 12:22:58 -0700 (PDT)
In-Reply-To: <B5657A6538887040AD3A81F1008BEC63B4152D@avmb3.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-09-30 at 19:05 +0000, Yuval Mintz wrote:

> Can you pinpoint me to what exactly in the code corrects NAPI_GRO_CB(skb)->csum
> by negating the ipv4 part in the ones' complete checksum?
> 
> E.g., for ipv6 [in ipv6_gro_receive()] I can see that skb_gro_postpull_rcsum() is
> called after pulling the ipv6 header [and before proceeding to the next protocol],
> but I can't seem to find anything similar to this for ipv4 [in inet_gro_receive()].
> 


IPv4 header is supposed to have a 0 checksum ;)
