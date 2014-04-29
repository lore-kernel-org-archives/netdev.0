From: Tobias Klauser <tobias.klauser@gmail.com>
Subject: Re: [PATCH net v2] Altera TSE: Fix DMA secriptor length initialization
Date: Tue, 29 Apr 2014 09:05:21 +0200
Message-ID: <CAP6CguWyFAu7Ge2JXTqqH8qyXGgzgv-TnKszu3joz29_QgfPJw@mail.gmail.com>
References: <1398720181-19450-1-git-send-email-tklauser@distanz.ch>
	<CAOwfj2OsHQjiAE_Nznt-3yoiTx9BESrQ8QdNb6xLqH3=qBJwdg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	nios2-dev <nios2-dev@lists.rocketboards.org>
To: Vince Bridgers <vbridgers2013@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:39735 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755828AbaD2HFW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2014 03:05:22 -0400
Received: by mail-wg0-f50.google.com with SMTP id k14so2858653wgh.21
        for <netdev@vger.kernel.org>; Tue, 29 Apr 2014 00:05:21 -0700 (PDT)
In-Reply-To: <CAOwfj2OsHQjiAE_Nznt-3yoiTx9BESrQ8QdNb6xLqH3=qBJwdg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29 April 2014 00:37, Vince Bridgers <vbridgers2013@gmail.com> wrote:
> On Mon, Apr 28, 2014 at 4:23 PM, Tobias Klauser
> <tobias.klauser@gmail.com> wrote:
>> sgdma_descrip is a function name as well as the name of a struct. In
>> sgdma_initialize(), we should initialize the descriptor length field
>> with the actual length of a descriptor not with the size of the
>> function. In order to prevent such things from happening in the future,
>> rename the function to sgdma_setup_descrip().
>>
>> Found by sparse which yields the following warning:
>>
>> drivers/net/ethernet/altera/altera_sgdma.c:74:30: warning: expression using sizeof on a function
>>
>> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
>> ---
>> v2: patchd rebase against current net tree
>>
>
> Thanks for the patch Tobias. Was the misspelling in the subject line
> an oversight (secriptor -> descriptor) ?

Yes, this was an oversight, sorry. Thanks for pointing out.

Dave, shall I send an updated patch with the correct subject line or can
you fix it up before applying?

Thanks
Tobias
