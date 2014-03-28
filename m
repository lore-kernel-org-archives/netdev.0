From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: Re: [PATCH net 1/4] qlge: Do not propaged vlan tag offloads to vlans
Date: Fri, 28 Mar 2014 03:32:23 +0000
Message-ID: <BECD8E8A1B550B48A1BF97C13991F60E46D3C3AD@avmb2.qlogic.org>
References: <1395972889-32289-1-git-send-email-vyasevic@redhat.com>
 <1395972889-32289-2-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Ron Mercer <ron.mercer@qlogic.com>
To: Vlad Yasevich <vyasevic@redhat.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:37839 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755681AbaC1Dc1 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2014 23:32:27 -0400
In-Reply-To: <1395972889-32289-2-git-send-email-vyasevic@redhat.com>
Content-Language: en-US
Content-ID: <6A90A4E7317618439AB3E4433AA415B5@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 3/27/14 7:14 PM, "Vlad Yasevich" <vyasevic@redhat.com> wrote:

>qlge driver turns off NETIF_F_HW_CTAG_FILTER, but forgets to
>turn off HW_CTAG_TX and HW_CTAG_RX on vlan devices.  With the
>current settings, q-in-q will only generate a single vlan header.
>Remember to mask off CTAG_TX and CTAG_RX features in vlan_features.
>
>CC: Shahed Shaikh <shahed.shaikh@qlogic.com>
>CC: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
>CC: Ron Mercer <ron.mercer@qlogic.com>
>Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
>---
> drivers/net/ethernet/qlogic/qlge/qlge_main.c | 4 +++-
> 1 file changed, 3 insertions(+), 1 deletion(-)

Acked-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
