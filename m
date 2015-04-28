From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] net/macb: Fix UDPv4 checksum offload
Date: Tue, 28 Apr 2015 16:47:51 -0400 (EDT)
Message-ID: <20150428.164751.1765242259665119244.davem@davemloft.net>
References: <1430174610-6834-1-git-send-email-jaeden.amero@ni.com>
	<20150427.224713.291017556251723132.davem@davemloft.net>
	<553FEF66.7010503@ni.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jeff.westfahl@ni.com,
	mihai.neagu@ni.com
To: jaeden.amero@ni.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <553FEF66.7010503@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jaeden Amero <jaeden.amero@ni.com>
Date: Tue, 28 Apr 2015 15:36:54 -0500

> On 04/27/2015 09:47 PM, David Miller wrote:
>> From: Jaeden Amero <jaeden.amero@ni.com>
>> Date: Mon, 27 Apr 2015 17:43:30 -0500
>>
>> A UDP checksum of zero, means "checksum not computed".  And your
>> device isn't computing the checksum at all, but rather is leaving it
>> at zero.
> 
> The "zero" checksum is not what gets sent over the wire. Independent of
> the value of the checksum field, hardware generates a correct checksum
> for payloads of 3 or more bytes. The bug is that hardware generates an
> incorrect checksum for payloads of 2 or less bytes, unless the checksum
> field is zeroed.

Ok, then you need to add a comment here, because other people might come
to the same conclusion I did.
