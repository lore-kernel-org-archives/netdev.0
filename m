From: Dmitry Kravkov <dkravkov@gmail.com>
Subject: Re: [PATCH net] net: tg3: fix NULL pointer dereference in
 tg3_io_error_detected and tg3_io_slot_reset
Date: Thu, 15 Aug 2013 13:57:33 +0300
Message-ID: <CAM8tLiP8mdpXGTU4CUcAVjLVBWcKCgE0amao+y7e_-9Jm8R0ng@mail.gmail.com>
References: <1376419513-31924-1-git-send-email-nsujir@broadcom.com>
	<20130815.010726.719593168454341579.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: nsujir@broadcom.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	dborkman@redhat.com, shangw@linux.vnet.ibm.com,
	Michael Chan <mchan@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f43.google.com ([209.85.214.43]:50137 "EHLO
	mail-bk0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754124Ab3HOK5f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 06:57:35 -0400
Received: by mail-bk0-f43.google.com with SMTP id mz13so170047bkb.2
        for <netdev@vger.kernel.org>; Thu, 15 Aug 2013 03:57:34 -0700 (PDT)
In-Reply-To: <20130815.010726.719593168454341579.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 15, 2013 at 11:07 AM, David Miller <davem@davemloft.net> wrote:
>
> From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
> Date: Tue, 13 Aug 2013 11:45:13 -0700
>
> > From: Daniel Borkmann <dborkman@redhat.com>
> >
> > Commit d8af4dfd8 ("net/tg3: Fix kernel crash") introduced a possible
> > NULL pointer dereference in tg3 driver when !netdev || !netif_running(netdev)
> > condition is met and netdev is NULL. Then, the jump to the 'done' label
> > calls dev_close() with a netdevice that is NULL. Therefore, only call
> > dev_close() when we have a netdevice, but one that is not running.
> >
> > [ Add the same checks in tg3_io_slot_reset() per Gavin Shan - by Nithin
> > Nayak Sujir ]
> >
> > Reported-by: Dave Jones <davej@redhat.com>
> > Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> > Cc: Gavin Shan <shangw@linux.vnet.ibm.com>
> > Cc: Michael Chan <mchan@broadcom.com>
> > Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
>
> Can I get some reviews from the Broadcom folks?
>
> Thanks.

You already have:
Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
