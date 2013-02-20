From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] net: fix a wrong assignment in skb_split()
Date: Wed, 20 Feb 2013 15:13:03 -0500 (EST)
Message-ID: <20130220.151303.200159114555025820.davem@davemloft.net>
References: <1361350290-28581-1-git-send-email-amwang@redhat.com>
	<CALnjE+rwqV_APx-epsaiF6KjvjSmXU=iORwVyNov8Zvk9we0HQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amwang@redhat.com, netdev@vger.kernel.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49676 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934126Ab3BTUNG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2013 15:13:06 -0500
In-Reply-To: <CALnjE+rwqV_APx-epsaiF6KjvjSmXU=iORwVyNov8Zvk9we0HQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin Shelar <pshelar@nicira.com>
Date: Wed, 20 Feb 2013 10:42:18 -0800

> On Wed, Feb 20, 2013 at 12:51 AM, Cong Wang <amwang@redhat.com> wrote:
>> commit c9af6db4c11ccc6c3e7f1 (net: Fix possible wrong checksum generation)
>> has a suspicous piece:
>>
>>         -       skb_shinfo(skb1)->gso_type = skb_shinfo(skb)->gso_type;
>>         -
>>         +       skb_shinfo(skb)->tx_flags = skb_shinfo(skb1)->tx_flags & SKBTX_SHARED_FRAG;
>>
>> skb1 is the new skb, therefore should be on the left side of the assignment.
>> This patch fixes it.
>>
>> Cc: Pravin B Shelar <pshelar@nicira.com>
>> Cc: David S. Miller <davem@davemloft.net>
>> Signed-off-by: Cong Wang <amwang@redhat.com>
>>
> Looks good.
> 
> Acked-by: Pravin B Shelar <pshelar@nicira.com>

Applied, thanks.
