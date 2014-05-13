From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 8/8] vxlan: Add support for zero UDP6 checksums
Date: Tue, 13 May 2014 15:59:35 -0700
Message-ID: <CA+mtBx8Gt2Mm9bWE=Y01LkrvfctgaKWfZTiWsLb3M-mHu-YpLg@mail.gmail.com>
References: <alpine.DEB.2.02.1405120952470.12635@tomh.mtv.corp.google.com>
	<20140513.184802.1863631448443267898.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:59954 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752687AbaEMW7g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 18:59:36 -0400
Received: by mail-ie0-f170.google.com with SMTP id ar20so1095554iec.1
        for <netdev@vger.kernel.org>; Tue, 13 May 2014 15:59:35 -0700 (PDT)
In-Reply-To: <20140513.184802.1863631448443267898.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 13, 2014 at 3:48 PM, David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <therbert@google.com>
> Date: Mon, 12 May 2014 09:59:25 -0700 (PDT)
>
>> Added module parameters to specify sending of TX checksums and
>> allow receiving RX checksums. Also added a module parameter and
>> support for using IPv4 checksums on TX (default is off so zero
>> checksums are sent).
>>
>> Signed-off-by: Tom Herbert <therbert@google.com>
>
> Tom, definitely do not do this using module parameters.
>
> Extend the vxlan configuration to suppose this switch using netlink.
>
Acknowledged.

> Thanks.
