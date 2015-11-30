From: Luuk Paulussen <Luuk.Paulussen@alliedtelesis.co.nz>
Subject: Re: Increasing skb->mark size
Date: Mon, 30 Nov 2015 04:10:43 +0000
Message-ID: <565BCC42.7020701@alliedtelesis.co.nz>
References: <1448397144.14854.27.camel@mattb-dl>
 <CAKD1Yr3URKzAooiNH7i4kHVR0-TQjEAkQEdqjarAm6uxH7u-Mw@mail.gmail.com>
 <20151129.205854.160622377475841200.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Matt Bennett <Matt.Bennett@alliedtelesis.co.nz>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	"lorenzo@google.com" <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate2.alliedtelesis.co.nz ([202.36.163.20]:33617 "EHLO
	gate2.alliedtelesis.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751788AbbK3EK4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2015 23:10:56 -0500
In-Reply-To: <20151129.205854.160622377475841200.davem@davemloft.net>
Content-Language: en-US
Content-ID: <287D04248E6DD047AB340511FE7BE9B6@atlnz.lc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/30/2015 02:58 PM, David Miller wrote:
> If you guys, really anyone, can find a way to remove some other 32-bit 
> item from sk_buff, you can expand skb->mark to 64-bits. But otherwise, 
> I'm going to be strongly against it. sk_buff is already enormous and 
> larger than it should be. So I'm going to resist any change that makes 
> it even larger. Thanks. 
Would the level of objection be the same if this was done as an 
"extended mark" field under a configurable off-by-default option? This 
would allow users who need this functionality to enable it while making 
it clear that this is at the expense of increasing sk_buff size.