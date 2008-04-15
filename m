From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: Why MLDv2 Report packet is freed ?
Date: Tue, 15 Apr 2008 23:48:44 +0900 (JST)
Message-ID: <20080415.234844.99535411.yoshfuji@linux-ipv6.org>
References: <d0383f90804150623r2eb071fau200a67c6ce65a7e0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: ianbrn@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:33557 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754662AbYDOOqy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 10:46:54 -0400
In-Reply-To: <d0383f90804150623r2eb071fau200a67c6ce65a7e0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <d0383f90804150623r2eb071fau200a67c6ce65a7e0@mail.gmail.com> (at Tue, 15 Apr 2008 16:23:33 +0300), "Ian Brown" <ianbrn@gmail.com> says:

> Now, I don't understand something here:
> I had looked at icmpv6_rcv() in net/ipv6/icmp.c.
> 
> I see that when the type of the ICMP packet is ICMPV6_MLD2_REPORT it
> is dropped (calling kfree_skb()).
> 
> shouldn't it be handled and passed onward so that it will
> eventually reach the pim6sd daemon ? or is this
> only implemented currently for MLDV1 ?

In MLDv1, Report suppress other hosts' reports, but 
On the other hand, in MLDv2, Reports does not suppress.
So, MLDv2 Report is useless for in-kernel MLD handler.

MLD packets are handled in other place.

--yoshfuji
