From: Jon Mason <jon.mason@broadcom.com>
Subject: Re: [PATCH 2/2] net: ethernet: bgmac: mac address change bug
Date: Thu, 2 Feb 2017 13:13:26 -0500
Message-ID: <CAC3K-4pNmzVuLN-ag0wMiWHketRTXy8=apWRDvRE5-rWy=4a2A@mail.gmail.com>
References: <1485988752-21030-1-git-send-email-jon.mason@broadcom.com>
 <1485988752-21030-3-git-send-email-jon.mason@broadcom.com> <bee62170-c890-bd9e-5842-7c87ff96542c@milecki.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: David Miller <davem@davemloft.net>,
        BCM Kernel Feedback <bcm-kernel-feedback-list@broadcom.com>,
        Network Development <netdev@vger.kernel.org>,
        open list <linux-kernel@vger.kernel.org>,
        Hari Vyas <hariv@broadcom.com>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <rafal@milecki.pl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <bee62170-c890-bd9e-5842-7c87ff96542c@milecki.pl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 1, 2017 at 6:12 PM, Rafa=C5=82 Mi=C5=82ecki <rafal@milecki.pl> =
wrote:
> On 02/01/2017 11:39 PM, Jon Mason wrote:
>>
>> From: Hari Vyas <hariv@broadcom.com>
>>
>> ndo_set_mac_address() passes struct sockaddr * as 2nd parameter to
>> bgmac_set_mac_address() but code assumed u8 *.  This caused two bytes
>> chopping and the wrong mac address was configured.
>>
>> Signed-off-by: Hari Vyas <hariv@broadcom.com>
>> Signed-off-by: Jon Mason <jon.mason@broadcom.com>
>> Fixes: 4e209001b86 ("bgmac: write mac address to hardware in
>> ndo_set_mac_address")
>
>
> Sounds OK, would it make sense to Cc stable?

Sure, I'll add Sergei's mods and do a v2 with stable on the Cc list
