From: Rasesh Mody <rmody@brocade.com>
Subject: RE: [net-next 04/12] bna: TX Path and RX Path Changes
Date: Tue, 23 Aug 2011 11:06:41 -0700
Message-ID: <E5313AF6F2BFD14293E5FD0F94750F86A9E4B8C251@HQ1-EXCH01.corp.brocade.com>
References: <1314052869-7407-1-git-send-email-rmody@brocade.com>
	<1314052869-7407-5-git-send-email-rmody@brocade.com>
 <20110822.164541.1084485895386350206.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Adapter Linux Open SRC Team"
	<adapter_linux_open_src_team@Brocade.COM>,
	Gurunatha Karaje <gkaraje@Brocade.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:39685 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754103Ab1HWSGt convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Aug 2011 14:06:49 -0400
In-Reply-To: <20110822.164541.1084485895386350206.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From: David Miller [mailto:davem@davemloft.net]
>Sent: Monday, August 22, 2011 4:46 PM
>
>From: Rasesh Mody <rmody@brocade.com>
>Date: Mon, 22 Aug 2011 15:41:01 -0700
>
>> +		if (unlikely(skb_is_gso(skb) > netdev->mtu)) {
>
>skb_is_gso() is mean to be a boolean test, it happens to return
>the value of ->gso_size as it's implementation but that's not
>a good reason for you to abuse this interface in this way.
>
>If we every fix skb_is_gso() to return a true 'bool' your driver
>will break.
>
>Access ->gso_size directly if that's what you're interested in,
>that way it's future proof and won't break in the future.

Hi Dave,
We've addressed this by accessing ->gso_size directly and resubmitted
the patch-set.
Thanks for the suggestion,
--Rasesh

