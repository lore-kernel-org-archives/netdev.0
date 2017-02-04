From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH net-next v2 00/12] bnxt_en: Add XDP support.
Date: Fri, 3 Feb 2017 17:32:16 -0800
Message-ID: <CACKFLikT+o2Uov7Yx3U5zro=cmVasM1Ufa=xxCajDTTV5JeAAA@mail.gmail.com>
References: <1486054540-366-1-git-send-email-michael.chan@broadcom.com>
 <20170203.154910.2213640966872850071.davem@davemloft.net> <CACKFLimXCkC1=9kvQnz-s5rjTOGe1gmb9Ozvt1tEeW+O=y7yAg@mail.gmail.com>
 <20170203.165054.437855043325795801.davem@davemloft.net> <20170203163003.00d794dc@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Netdev <netdev@vger.kernel.org>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f47.google.com ([209.85.213.47]:33579 "EHLO
        mail-vk0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753324AbdBDBcR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 20:32:17 -0500
Received: by mail-vk0-f47.google.com with SMTP id k127so24623144vke.0
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 17:32:17 -0800 (PST)
In-Reply-To: <20170203163003.00d794dc@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 3, 2017 at 4:33 PM, Jakub Kicinski <kubakici@wp.pl> wrote:
> On Fri, 03 Feb 2017 16:50:54 -0500 (EST), David Miller wrote:
>> We don't set precedence by one driver saying "hey it's better to do
>> things this way, forget what all the other drivers are doing."  Rather
>> we have a "discussion" about what the appropriate thing is to do and
>> convert all the drivers only after a decision has been made.
>
> Would making sure that if xdp_adjust_head() changes the starting offset
> (and length) of frame and the program returns XDP_PASS - the stack will
> see the changes made by xdp_adjust_head() fall under the same follow
> the precedent rule?  That is what Martin did for mlx4 and mlx5, and what
> John did in virtio, but not what this patch set does (see my comment on
> patch 11).
>
> I should have double checked mlx4/mlx5 and made it clearer that there is
> a precedent here in my review comment...

Yes, I plan to also include this change (make modified offset and
length visible to the stack) in the next version of the patch set.
