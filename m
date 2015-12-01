From: Luuk Paulussen <Luuk.Paulussen@alliedtelesis.co.nz>
Subject: Re: Increasing skb->mark size
Date: Tue, 1 Dec 2015 04:57:18 +0000
Message-ID: <565D28AE.3060204@alliedtelesis.co.nz>
References: <565BCC42.7020701@alliedtelesis.co.nz>
 <20151129.234955.2156041834628417171.davem@davemloft.net>
 <565CE5E8.9010002@alliedtelesis.co.nz>
 <20151130.225551.1151915829635053889.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "lorenzo@google.com" <lorenzo@google.com>,
	Matt Bennett <Matt.Bennett@alliedtelesis.co.nz>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate2.alliedtelesis.co.nz ([202.36.163.20]:37400 "EHLO
	gate2.alliedtelesis.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752625AbbLAE5a convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2015 23:57:30 -0500
In-Reply-To: <20151130.225551.1151915829635053889.davem@davemloft.net>
Content-Language: en-US
Content-ID: <51BC3F094BD0D248B27D5C596F57B32E@atlnz.lc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/01/2015 04:55 PM, David Miller wrote:
> Lots of things are interesting and useful to many people.
>
> Even the most useful feature I would balk at it's implementation
> if it bloated up sk_buff.  Period.
>
> You don't understand what the core issue is, which is sk_buff size
> which has an effect on all users.

I have understood the core issue, which is why the rest of the email was 
proposing an alternative solution that didn't involve increasing sk_buff 
size at all (I would still like a comment on the possibility of adding a 
tc_index field to the nf_conn structure to match the one in the skb).
