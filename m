From: Tsutomu Fujii <t-fujii@nb.jp.nec.com>
Subject: Re: Bonding in active-backup mode with arp monitoring on Xen
Date: Wed, 31 Oct 2007 20:08:44 +0900
Message-ID: <4728623C.4000906@nb.jp.nec.com>
References: <47253487.3010909@nb.jp.nec.com> <25246.1193780909@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO202.gate.nec.co.jp ([202.32.8.206]:57507 "EHLO
	tyo202.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755477AbXJaLIs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2007 07:08:48 -0400
In-Reply-To: <25246.1193780909@death>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi.

Jay Vosburgh wrote:
> 	I'm not sure if this is a solution that will work for any peer
> (some peers may not reply to an ARP with an IP source of all zeros).  At
> first glance, there doesn't seem to be much of a downside, but I'll have
> to experiment with it a bit to see if the check should be optional or
> simply removed entirely.

If there are no downside, I think it is better to remove the check.
For your information, other mode that can use arp monitoring send an
ARP with an IP source of all zero.

Thanks.

--
Tsutomu Fujii
