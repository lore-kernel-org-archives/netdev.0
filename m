From: Michael D <michael.j.dilmore@gmail.com>
Subject: Re: [PATCH] Convert BUG_ON to WARN_ON in bond_options.c
Date: Wed, 21 Jun 2017 22:41:07 +0100
Message-ID: <CALRmy5tn6cgWF5LP5i7w+UTwP1UJCyQoC7Mx7=RvETBUVD-yuw@mail.gmail.com>
References: <1498068137-3550-1-git-send-email-michael.j.dilmore@gmail.com>
 <21644.1498070000@famine> <CALRmy5sYL_gJsiLzQQn-2FbWowi=Bj4DkYdcOdrOHeSs4jQ3Xg@mail.gmail.com>
 <20170621.173655.1945994342723484710.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jay Vosburgh <jay.vosburgh@canonical.com>,
        Veaceslav Falico <vfalico@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Joe Perches <joe@perches.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170621.173655.1945994342723484710.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I don't think you can stop it being dereferenced... you just need to
prevent an attacker from exploiting the null pointer dereference
vulnerability right? And this is done by returning the function right
away?





On 21 June 2017 at 22:36, David Miller <davem@davemloft.net> wrote:
> From: Michael D <michael.j.dilmore@gmail.com>
> Date: Wed, 21 Jun 2017 22:35:56 +0100
>
>> How do we actually stop a null pointer being dereferenced here?
>
> Maybe that's why it's a BUG_ON(), there is no reasonable way
> to continue if the pointer is NULL.
>
