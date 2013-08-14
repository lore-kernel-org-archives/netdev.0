From: poma <pomidorabelisima@gmail.com>
Subject: Re: [PATCH net] skge: dma_sync the whole receive buffer
Date: Wed, 14 Aug 2013 12:20:03 +0200
Message-ID: <520B59D3.4020103@gmail.com>
References: <20130810104100.0ae20aa6@nehalam.linuxnetplumber.net> <20130810.132935.1257046025460198490.davem@davemloft.net> <20130810150207.37432299@nehalam.linuxnetplumber.net> <20130813.150955.1471100759610399160.davem@davemloft.net> <20130813180036.3e639789@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:35361 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752162Ab3HNKUH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Aug 2013 06:20:07 -0400
Received: by mail-wi0-f180.google.com with SMTP id f14so1735499wiw.13
        for <netdev@vger.kernel.org>; Wed, 14 Aug 2013 03:20:06 -0700 (PDT)
In-Reply-To: <20130813180036.3e639789@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14.08.2013 03:00, Stephen Hemminger wrote:
> On Tue, 13 Aug 2013 15:09:55 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
>> From: Stephen Hemminger <stephen@networkplumber.org>
>> Date: Sat, 10 Aug 2013 15:02:07 -0700
>>
>>> The DMA sync should sync the whole receive buffer, not just
>>> part of it. Fixes log messages dma_sync_check.
>>>
>>> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
>>
>> Applied, but I really suspect that your "check DMA mapping errors"
>> patch has added a serious regression.  A regression much worse than
>> the bug you were trying to fix with that change.
> 
> Argh. The problem is deeper than that. Device got broken somewhere between
> 3.2 and 3.4. My old Dlink card works on 3.2 but gets DMA errors on 3.4.
> The config's are different though so checking that as well.
> 

Can I help you with debugging?
DGE-530T is rather solid device.


poma
