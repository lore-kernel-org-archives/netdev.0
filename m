From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 10/10] bnxt_en: add support for port_attr_get and
 and get_phys_port_name
Date: Wed, 26 Jul 2017 12:13:35 +0300
Message-ID: <CAJ3xEMj4OznaiaxT6sSuS9aUxoTDJmJbKKa=WyX_=Xhd8RVs2A@mail.gmail.com>
References: <1500914069-15724-1-git-send-email-michael.chan@broadcom.com>
 <1500914069-15724-11-git-send-email-michael.chan@broadcom.com> <20170724214521.75bf5857@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Michael Chan <michael.chan@broadcom.com>,
        David Miller <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Sathya Perla <sathya.perla@broadcom.com>,
        Jiri Pirko <jiri@mellanox.com>
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:37590 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750826AbdGZJNh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 05:13:37 -0400
Received: by mail-oi0-f68.google.com with SMTP id j194so6661691oib.4
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2017 02:13:36 -0700 (PDT)
In-Reply-To: <20170724214521.75bf5857@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 25, 2017 at 7:45 AM, Jakub Kicinski <kubakici@wp.pl> wrote:

> This is even worse.  We already have two naming conventions in the
> kernel, mlx5 uses "%d" for legacy reasons.  nfp uses pf%dvf%d for vfs,

To make it clear, in mlx5 this is used only for the offloads/switchdev mode
and not for legacy mode, in the latter mode, a  VF probed to VM doesn't
have host side representation so there's no where to use that.

Or.

> which is better for two reasons: (a) it works with multi-PF devices;
> (b) naming something representor from switchdev perspective is
> pointless, you're not calling the external port netdev a physical port
> representor, even though it has the exact same relation to the port as
> with VFs (i.e. egressing traffic on the netdev will cause the switch
> to send to the given port).
