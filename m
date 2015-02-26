From: Eyal Birger <eyal.birger@gmail.com>
Subject: Re: [PATCH net-next 1/7] net: bluetooth: compact struct bt_skb_cb by
 inlining struct hci_req_ctrl
Date: Thu, 26 Feb 2015 23:22:50 +0200
Message-ID: <CAHsH6GtrrJTTo58ih3xV5-+W8fe08u_70ZVXzZG7K5gx2E2a1Q@mail.gmail.com>
References: <1424916612-744-1-git-send-email-eyal.birger@gmail.com>
	<1424916612-744-2-git-send-email-eyal.birger@gmail.com>
	<8FC7DD28-25D4-4BB7-AB6F-13FC94E18176@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f49.google.com ([209.85.213.49]:35817 "EHLO
	mail-yh0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753937AbbBZVWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 16:22:51 -0500
Received: by yhoc41 with SMTP id c41so5997036yho.2
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 13:22:51 -0800 (PST)
In-Reply-To: <8FC7DD28-25D4-4BB7-AB6F-13FC94E18176@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Marcel,

On Thu, Feb 26, 2015 at 6:15 PM, Marcel Holtmann <marcel@holtmann.org> wrote:
> Hi Eyal,
>
>> struct hci_req_ctrl is never used outside of struct bt_skb_cb;
>> Inlining it frees 8 bytes on a 64 bit system in skb->cb[] allowing
>> the addition of more ancillary data.
>>
>> Signed-off-by: Eyal Birger <eyal.birger@gmail.com>
>> ---
>> include/net/bluetooth/bluetooth.h | 10 +++-------
>> net/bluetooth/hci_core.c          | 12 ++++++------
>> net/bluetooth/hci_event.c         |  4 ++--
>> net/bluetooth/hci_request.c       |  6 +++---
>> net/bluetooth/hci_sock.c          |  2 +-
>> 5 files changed, 15 insertions(+), 19 deletions(-)
>
> it would be a really good idea to actually send this to linux-bluetooth@vger.kernel.org for review.
>

Thanks! I have done that in v2.

Eyal.
