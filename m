From: Jim Cromie <jim.cromie@gmail.com>
Subject: Re: [PATCH] natsemi: silence dma-debug warnings
Date: Sat, 9 Jul 2011 19:45:22 -0600
Message-ID: <CAJfuBxxs=CEBV+v+8GkYyabVobhwiXKYc5qHhZE-ZKFxywkQaQ@mail.gmail.com>
References: <20110704142153O.fujita.tomonori@lab.ntt.co.jp>
 <20110703.223448.458910310802724750.davem@davemloft.net> <CAJfuBxxKYNvaw5t4jWMP4+hYcw42SkwLiiahVdeezpfh6AsLBA@mail.gmail.com>
 <20110710.102039.1305564732068163396.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, thockin@hockin.org, netdev@vger.kernel.org
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:36989 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755100Ab1GJBpw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jul 2011 21:45:52 -0400
Received: by pwj7 with SMTP id 7so1886821pwj.19
        for <netdev@vger.kernel.org>; Sat, 09 Jul 2011 18:45:52 -0700 (PDT)
In-Reply-To: <20110710.102039.1305564732068163396.fujita.tomonori@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 9, 2011 at 7:20 PM, FUJITA Tomonori
<fujita.tomonori@lab.ntt.co.jp> wrote:
> On Sat, 9 Jul 2011 14:11:25 -0600
> Jim Cromie <jim.cromie@gmail.com> wrote:
>
>> On Sun, Jul 3, 2011 at 11:34 PM, David Miller <davem@davemloft.net> =
wrote:
>>> From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
>>> Date: Mon, 4 Jul 2011 14:30:19 +0900
>>>
>>>> This silences dma-debug warnings:
>>>>
>>>> https://lkml.org/lkml/2011/6/30/341
>>> =A0...
>>>> Reported-by: Jim Cromie <jim.cromie@gmail.com>
>>>> Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
>>>> Tested-by: Jim Cromie <jim.cromie@gmail.com>
>>>
>>> Applied, thanks!
>>>
>>
>> I have since seen a similar warning on shutdown,
>> heres a patch for it.
>
> Oops, I noticed this too but I forgot to send a patch.
>
> The patch looks good to me.
>
>
>> theres one other callsite, but I havent seen the warning from it,
>> will try to tickle it at some point.
>
> Which pci_unmap_single are you talking about?
>


   2131 static void netdev_tx_done(struct net_device *dev)
   2132 {
=2E..
   2160                 pci_unmap_single(np->pci_dev,np->tx_dma[entry],
   2161                                         np->tx_skbuff[entry]->l=
en,
   2162                                         PCI_DMA_TODEVICE);
