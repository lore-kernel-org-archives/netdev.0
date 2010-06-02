From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [Patch]8139too: remove unnecessary cast of ioread32()'s return
 value
Date: Wed, 02 Jun 2010 13:52:52 -0400
Message-ID: <4C069A74.503@garzik.org>
References: <20100530.153451.193700815.davem@davemloft.net>	<4C02F3A2.90100@garzik.org>	<20100530.182948.71104948.davem@davemloft.net> <20100530.183557.104047217.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:38838 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754377Ab0FBRwz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 13:52:55 -0400
Received: by gye5 with SMTP id 5so2371809gye.19
        for <netdev@vger.kernel.org>; Wed, 02 Jun 2010 10:52:54 -0700 (PDT)
In-Reply-To: <20100530.183557.104047217.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/30/2010 09:35 PM, David Miller wrote:
> From: David Miller<davem@davemloft.net>
> Date: Sun, 30 May 2010 18:29:48 -0700 (PDT)
>
>> From: Jeff Garzik<jeff@garzik.org>
>> Date: Sun, 30 May 2010 19:24:18 -0400
>>
>>> That was the genesis of the question.  Some arches still use unsigned
>>> long.
>>
>> They are 32-bit.
>
> In fact the only two offenders are h8300 and m32r, which are
> both 32-bit.

The main interesting one is an ARM sub-arch that supports PCI.


> This is really in the realm of "who cares."

Fair enough.  That answers my question.

	Jeff



