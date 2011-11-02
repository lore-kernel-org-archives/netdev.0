From: Vasily Averin <vvs@parallels.com>
Subject: Re: [PATCH] bridge: Reset IPCB on forward non-local packets in br_handle_frame_finish()
Date: Thu, 03 Nov 2011 00:03:53 +0400
Message-ID: <4EB1A229.9030602@parallels.com>
References: <4EB19549.4010601@parallels.com> <20111102123106.107f4cb8@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.hengli.com.au>, devel@openvz.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:19719 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750891Ab1KBUEK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Nov 2011 16:04:10 -0400
In-Reply-To: <20111102123106.107f4cb8@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/02/2011 11:31 PM, Stephen Hemminger wrote:
> On Wed, 02 Nov 2011 23:08:57 +0400
> Vasily Averin <vvs@parallels.com> wrote:
> 
>> if dst is not local br_handle_frame_finish() does not clone original skb and
>> forgets to reset IPCB before return to IP stack. it can lead to stack corruption
>> in icmp_send()

> What kernel version are you using? There were several previous fixes
> in br_netfilter to deal with this type of issue over the last year.

Originally it was noticed on RHEL6-based kernel

You are right, in mainline this issue was fixed in br_nf_forward_ip() long time ago.

thank you,
	Vasily Averin
