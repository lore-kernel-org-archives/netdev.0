From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH v2 net-next 1/1] net sched actions: mirred add support for
 setting Dst MAC address
Date: Sat, 2 Jul 2016 09:58:22 -0700
Message-ID: <CAM_iQpXpkUo2H=Yndb4u63yKk6jNBbxYynmWtQRGhw6SAVUZrA@mail.gmail.com>
References: <1467470065-17613-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	nikolay@cumulusnetworks.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:33694 "EHLO
	mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752250AbcGBQ6m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jul 2016 12:58:42 -0400
Received: by mail-io0-f170.google.com with SMTP id t74so123922624ioi.0
        for <netdev@vger.kernel.org>; Sat, 02 Jul 2016 09:58:42 -0700 (PDT)
In-Reply-To: <1467470065-17613-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 2, 2016 at 7:34 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
>
> Often redirecting or mirroring requires that we set the dstMAC address
> of the target device. While it is possible to pipe to a pedit action,
> this patch obsoletes the need for that. This is a justified feature because
> the dst MAC addresses rewrite is such a common use case.

Maybe, instead of allowing to set arbitrary MAC address, how about
just allow setting to the MAC address of the target device?
If so we only need a boolean flag for user-space.

IOW, do we really need such flexibility?
