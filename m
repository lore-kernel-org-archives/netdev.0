From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net-next 0/2] bonding: remove rlb_enabled and alb_set_mac_address()
Date: Sun, 6 Jul 2014 16:56:26 +0300
Message-ID: <CAJZOPZKrkVEZGoCfP3wgvSMSK+5qO0syxxoQhWqhF_oBbooHnQ@mail.gmail.com>
References: <1400764324-23221-1-git-send-email-vfalico@gmail.com>
	<20140522.172217.1728568872131751930.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Veaceslav Falico <vfalico@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Amir Vadai <amirv@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f50.google.com ([209.85.192.50]:54676 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750856AbaGFN41 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jul 2014 09:56:27 -0400
Received: by mail-qg0-f50.google.com with SMTP id j5so2804554qga.9
        for <netdev@vger.kernel.org>; Sun, 06 Jul 2014 06:56:26 -0700 (PDT)
In-Reply-To: <20140522.172217.1728568872131751930.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 23, 2014 at 12:22 AM, David Miller <davem@davemloft.net> wrote:
>
> From: Veaceslav Falico <vfalico@gmail.com>
> Date: Thu, 22 May 2014 15:12:02 +0200
>
> > Currently rlb_enabled works as
> > rlb_enabled == (BOND_MODE(bond) == BOND_MODE_ALB)
> > so we can always use this verification and drop maintenance of this
> > variable.
> >
> > alb_set_mac_address(), OTOH, isn't used at all (as the mac changing logic
> > is used in other parts), and isn't ever called, so it's safe to remove it
> > as well.
> >
> > CC: Jay Vosburgh <j.vosburgh@gmail.com>
> > CC: Andy Gospodarek <andy@greyhouse.net>
> > CC: netdev@vger.kernel.org
> > Signed-off-by: Veaceslav Falico <vfalico@gmail.com>
>
> I agree with Jay's feedback and that you should:
>
> 1) Just go to the new MAC stash scheme in net-next instead of trying
>    to fix something you intend to immediately remove.
>
> 2) Something to fix this as minimally as possible for 'net' and
>    -stable should be done as well.
>
> I'm therefore not applying this series to the tree.

Hi Veaceslav ,

Just a reminder, any progress on this matter?

Or.
