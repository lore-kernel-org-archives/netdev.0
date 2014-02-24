From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] loopback: sctp: add NETIF_F_SCTP_CSUM to device
 features
Date: Mon, 24 Feb 2014 15:06:02 +0100
Message-ID: <530B51CA.3090606@redhat.com>
References: <1393074113-9922-1-git-send-email-dborkman@redhat.com> <063D6719AE5E284EB5DD2968C1650D6D0F6C96DE@AcuExch.aculab.com> <530B1F93.4010308@redhat.com> <063D6719AE5E284EB5DD2968C1650D6D0F6C9802@AcuExch.aculab.com> <530B34D3.2050307@redhat.com> <063D6719AE5E284EB5DD2968C1650D6D0F6C99F9@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58065 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752233AbaBXOHB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Feb 2014 09:07:01 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6C99F9@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/24/2014 02:24 PM, David Laight wrote:
...
> Maybe the _le has something to do with it.
> Could it be bit-reversing the crc and data bytes all the time?
> The packet will (one would hope) want the crc in the same bit-order
> as the data, so no bit reversal is needed - just the correct logic
> and lookup table.

Although it's a bit off-topic for this patch, but I'll have a look
into __crc32c_le(); maybe something is just wrong with that code.
