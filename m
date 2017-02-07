From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 1/3] ath10k: remove ath10k_vif_to_arvif()
Date: Tue, 07 Feb 2017 06:46:47 -0800
Message-ID: <5899DDD7.7000605@candelatech.com>
References: <1486030773-30600-1-git-send-email-amadeusz.slawinski@tieto.com> <CAJ-VmonrHpS3MArM9ohHgLvb6xspP_gnVVeJWA9F-pjUpJ+LZA@mail.gmail.com> <87y3xi4b28.fsf@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        =?UTF-8?B?QW1hZGV1c3ogU8WCYXdpxYRza2k=?=
        <amadeusz.slawinski@tieto.com>,
        "ath10k@lists.infradead.org" <ath10k@lists.infradead.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: "Valo, Kalle" <kvalo@qca.qualcomm.com>,
        Adrian Chadd <adrian@freebsd.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87y3xi4b28.fsf@qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 02/07/2017 01:14 AM, Valo, Kalle wrote:
> Adrian Chadd <adrian@freebsd.org> writes:
>
>> Removing this method makes the diff to FreeBSD larger, as "vif" in
>> FreeBSD is a different pointer.
>>
>> (Yes, I have ath10k on freebsd working and I'd like to find a way to
>> reduce the diff moving forward.)
>
> I don't like this "(void *) vif->drv_priv" style that much either but
> apparently it's commonly used in Linux wireless code and already parts
> of ath10k. So this patch just unifies the coding style.

Surely the code compiles to the same thing, so why add a patch that
makes it more difficult for Adrian and makes the code no easier to read
for the rest of us?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
