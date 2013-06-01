From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] udp6: Fix udp fragmentation for tunnel traffic.
Date: Fri, 31 May 2013 17:07:02 -0700 (PDT)
Message-ID: <20130531.170702.131332369869744840.davem@davemloft.net>
References: <1369932327-7913-1-git-send-email-pshelar@nicira.com>
	<CAM8tLiOi3sMeMecKgRLXq+RtEtY1Pvfeg9v2n-6M9k6WDiG9gg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, netdev@vger.kernel.org
To: dkravkov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43179 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754715Ab3FAAHD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 20:07:03 -0400
In-Reply-To: <CAM8tLiOi3sMeMecKgRLXq+RtEtY1Pvfeg9v2n-6M9k6WDiG9gg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <dkravkov@gmail.com>
Date: Thu, 30 May 2013 21:53:37 +0300

> On Thu, May 30, 2013 at 7:45 PM, Pravin B Shelar <pshelar@nicira.com> wrote:
>> udp6 over GRE tunnel does not work after to GRE tso changes. GRE
>> tso handler passes inner packet but keeps track of outer header
>> start in SKB_GSO_CB(skb)->mac_offset.  udp6 fragment need to
>> take care of outer header, which start at the mac_offset, while
>> adding fragment header.
>> This bug is introduced by commit 68c3316311 (GRE: Add TCP
>> segmentation offload for GRE).
>>
>> Reported-by: Dmitry Kravkov <dkravkov@gmail.com>
>> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
 ...
> Yeah, this fixes reported issue. Thanks.
> 
> Tested-by: Dmitry Kravkov <dmitry@broadcom.com>

Applied, thanks everyone.
