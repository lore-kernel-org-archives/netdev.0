From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net-next 2/2] bonding: remove alb_set_mac_address()
Date: Thu, 22 May 2014 17:36:19 +0300
Message-ID: <CAJZOPZKHm_0zpHQWSVrkcs4YsRbYSTWj1DU7SMG6PHHCeZcb3Q@mail.gmail.com>
References: <1400764324-23221-1-git-send-email-vfalico@gmail.com>
	<1400764324-23221-3-git-send-email-vfalico@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Eyal Perry <eyalpe@mellanox.com>
To: Veaceslav Falico <vfalico@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f47.google.com ([209.85.192.47]:47374 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751374AbaEVOgU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 10:36:20 -0400
Received: by mail-qg0-f47.google.com with SMTP id j107so5768558qga.20
        for <netdev@vger.kernel.org>; Thu, 22 May 2014 07:36:19 -0700 (PDT)
In-Reply-To: <1400764324-23221-3-git-send-email-vfalico@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 22, 2014 at 4:12 PM, Veaceslav Falico <vfalico@gmail.com> wrote:
>
> Currently it's called only from bond_alb_set_mac_address(), which is called
> only for ALB mode, and it does nothing in case the mode is ALB. So,
> basically, it's a no-op. All the needed functionality (modifying the active
> slave's mac address, per example) is handled by the
> bond_alb_set_mac_address() itself.

So with this patch @ hand, no more touching of the underlying device
dev_addr field directly -- or we still have more accesses of this
such, e.g in  bond_alb_set_mac_address() and/or friends?

Or.
