From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] Do not set shared_ports when nreq > MAX_MSIX
Date: Thu, 08 Oct 2015 04:54:54 -0700 (PDT)
Message-ID: <20151008.045454.1028964260721714737.davem@davemloft.net>
References: <1444166829-17638-2-git-send-email-clsoto@linux.vnet.ibm.com>
	<CAJ3xEMjYtmSj3kBo24w+4Y3Nh60C9J=NHb_=YQw1QASJ1i_i1g@mail.gmail.com>
	<5614411E.1070105@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gerlitz.or@gmail.com, matanb@mellanox.com, netdev@vger.kernel.org,
	ogerlitz@mellanox.com, brking@linux.vnet.ibm.com
To: clsoto@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60903 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752278AbbJHLjI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 07:39:08 -0400
In-Reply-To: <5614411E.1070105@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carol Soto <clsoto@linux.vnet.ibm.com>
Date: Tue, 6 Oct 2015 16:46:06 -0500

> 
> 
> On 10/6/2015 4:39 PM, Or Gerlitz wrote:
>> On Wed, Oct 7, 2015 at 12:27 AM,  <clsoto@linux.vnet.ibm.com> wrote:
>>> From: Carol L Soto <clsoto@linux.vnet.ibm.com>
>>>
>>> If we get MAX_MSIX interrupts would like to have each receive ring
>>> with his own msix interrupt line.
>> so 9293267a3e2a  was only partially correct? and/or not fully optimal?
>> please elaborate more on that in your change log.
> just not fully optimal, with commit 9293267a3e2a if I have 64 MSIXs
> and 2 ports I can get 8 rings for each port but then the rings will
> share the interrupt lines. For 64 MSIXs we can have each ring with his
> own interrupt line.
> 
>>> Fixes: 9293267a3e2a ('net/mlx4_core: Capping number of requested MSIXs
>>> to MAX_MSIX')
>>> Signed-off-by: Carol L Soto <clsoto@linux.vnet.ibm.com>
>> Carol, you didn't use net/mlx4: prefix as ask for mlx4 driver patch
>> titles, so please repost, but before that I'd like to see an ack from
>> Matan for this patch as well.
> Sorry completely missed it. When Matan acks will resend it.

Also please fix you subject to have a proper "mlx4: " subsystem prefix.
