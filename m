From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] geneve: fix incorrect setting of UDP checksum
 flag
Date: Sun, 30 Apr 2017 22:31:45 -0400 (EDT)
Message-ID: <20170430.223145.168447244341887933.davem@davemloft.net>
References: <1493327513-23247-1-git-send-email-girish.moodalbail@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@ovn.org
To: girish.moodalbail@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54236 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2999614AbdEACbw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 22:31:52 -0400
In-Reply-To: <1493327513-23247-1-git-send-email-girish.moodalbail@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Girish Moodalbail <girish.moodalbail@oracle.com>
Date: Thu, 27 Apr 2017 14:11:53 -0700

> Creating a geneve link with 'udpcsum' set results in a creation of link
> for which UDP checksum will NOT be computed on outbound packets, as can
> be seen below.
> 
> 11: gen0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN
>     link/ether c2:85:27:b6:b4:15 brd ff:ff:ff:ff:ff:ff promiscuity 0
>     geneve id 200 remote 192.168.13.1 dstport 6081 noudpcsum
> 
> Similarly, creating a link with 'noudpcsum' set results in a creation
> of link for which UDP checksum will be computed on outbound packets.
> 
> Fixes: 9b4437a5b870 ("geneve: Unify LWT and netdev handling.")
> Signed-off-by: Girish Moodalbail <girish.moodalbail@oracle.com>

Applied and queued up for -stable.
