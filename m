From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Convert BUG_ON to WARN_ON in bond_options.c
Date: Wed, 21 Jun 2017 17:56:51 -0400 (EDT)
Message-ID: <20170621.175651.854625612625047729.davem@davemloft.net>
References: <CALRmy5sYL_gJsiLzQQn-2FbWowi=Bj4DkYdcOdrOHeSs4jQ3Xg@mail.gmail.com>
        <20170621.173655.1945994342723484710.davem@davemloft.net>
        <CALRmy5tn6cgWF5LP5i7w+UTwP1UJCyQoC7Mx7=RvETBUVD-yuw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jay.vosburgh@canonical.com, vfalico@gmail.com, andy@greyhouse.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        joe@perches.com
To: michael.j.dilmore@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALRmy5tn6cgWF5LP5i7w+UTwP1UJCyQoC7Mx7=RvETBUVD-yuw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael D <michael.j.dilmore@gmail.com>
Date: Wed, 21 Jun 2017 22:41:07 +0100

> I don't think you can stop it being dereferenced... you just need to
> prevent an attacker from exploiting the null pointer dereference
> vulnerability right? And this is done by returning the function right
> away?

What's all of this about an "attacker"?

If there is a bug, we dererence a NULL pointer, and we should
fix that bug.

The BUG_ON() helps us see where the problem is while at the
same time stopping the kernel before the NULL deref happens.
