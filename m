From: Jon Mason <jon.mason@broadcom.com>
Subject: Re: [PATCH 1/2] net: ethernet: bgmac: init sequence bug
Date: Thu, 2 Feb 2017 15:20:07 -0500
Message-ID: <CAC3K-4o-8CHAeBmuginKdAhqhDpm8uv+8wjksX8q2xF7UB3E=A@mail.gmail.com>
References: <1485988752-21030-1-git-send-email-jon.mason@broadcom.com>
 <1485988752-21030-2-git-send-email-jon.mason@broadcom.com>
 <12ceba49-5465-072c-1770-b57d265bee86@milecki.pl> <CAMER8-WtBTR74YYfTkZWjrPQjdJ6ykaTPntGeB0Oor5rDnYJfQ@mail.gmail.com>
 <efd17b6863565d63b37b1bf75082d7b9@milecki.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Zac Schroff <zachary.schroff@broadcom.com>,
        David Miller <davem@davemloft.net>,
        BCM Kernel Feedback <bcm-kernel-feedback-list@broadcom.com>,
        Network Development <netdev@vger.kernel.org>,
        open list <linux-kernel@vger.kernel.org>,
        Zac Schroff <zschroff@broadcom.com>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <rafal@milecki.pl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <efd17b6863565d63b37b1bf75082d7b9@milecki.pl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 2, 2017 at 3:15 PM, Rafa=C5=82 Mi=C5=82ecki <rafal@milecki.pl> =
wrote:
> On 2017-02-02 01:31, Zac Schroff wrote:
>>
>> How about BCMA_IOCTL_PRESERVE_ACROSS_INIT?
>
>
> I think wireless drivers may still set some these bits during init.
>
> I've a simpler idea: make it bgmac specific. Call it sth like
> BGMAC_BCMA_IOCTL_PRESERVE
> BGMAC_BCMA_IOCTL_RESERVED
> BGMAC_BCMA_IOCTL_DONT_TOUCH

Yes, I am listing out all of the fields in that register.  We can be
intelligent about what we mask off :)
