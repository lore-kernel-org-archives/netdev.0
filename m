From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: Increasing skb->mark size
Date: Tue, 1 Dec 2015 21:42:45 -0800
Message-ID: <565E84D5.5070009@cumulusnetworks.com>
References: <1448397144.14854.27.camel@mattb-dl>
 <CAKD1Yr3URKzAooiNH7i4kHVR0-TQjEAkQEdqjarAm6uxH7u-Mw@mail.gmail.com>
 <87610ivv6u.fsf@tassilo.jf.intel.com> <565E1A9F.7040906@iogearbox.net>
 <20151202025835.GL15533@two.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Lorenzo Colitti <lorenzo@google.com>,
	Matt Bennett <Matt.Bennett@alliedtelesis.co.nz>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Luuk Paulussen <Luuk.Paulussen@alliedtelesis.co.nz>,
	davem@davemloft.net
To: Andi Kleen <andi@firstfloor.org>,
	Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:32931 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751178AbbLBFms (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 00:42:48 -0500
Received: by pabfh17 with SMTP id fh17so30599555pab.0
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2015 21:42:47 -0800 (PST)
In-Reply-To: <20151202025835.GL15533@two.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/1/15 6:58 PM, Andi Kleen wrote:
>>> - skb_iff is either skb->dev->iff or 0. so it could be replaced with a
>>> single bit flag for the 0 case.
>>
>> ... and that one wouldn't work on ingress.
>
> Please explain.

skb->dev is dropped fairly early in the Rx path. skb_iif is needed for 
example for IP_CMSG_PKTINFO.
