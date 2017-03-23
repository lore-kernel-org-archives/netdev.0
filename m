From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 1/3] soc: qcom: smd: Transition client drivers from smd
 to rpmsg
Date: Wed, 22 Mar 2017 19:23:04 -0700 (PDT)
Message-ID: <20170322.192304.1068066587902221771.davem@davemloft.net>
References: <20170320233544.1656-1-bjorn.andersson@linaro.org>
        <20170322.114439.679826829857326050.davem@davemloft.net>
        <21FCFC89-07EE-49EE-81C2-A138DD4C5F99@holtmann.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org,
        johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, k.eugene.e-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, andy.gross-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org,
        david.brown-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org,
        linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        wcn36xx-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-msm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-soc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <21FCFC89-07EE-49EE-81C2-A138DD4C5F99-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Date: Wed, 22 Mar 2017 20:23:15 +0100

> Hi Dave,
> 
>>> By moving these client drivers to use RPMSG instead of the direct SMD
>>> API we can reuse them ontop of the newly added GLINK wire-protocol
>>> support found in the 820 and 835 Qualcomm platforms.
>>> 
>>> As the new (RPMSG-based) and old SMD implementations are mutually
>>> exclusive we have to change all client drivers in one commit, to make
>>> sure we have a working system before and after this transition.
>>> 
>>> Signed-off-by: Bjorn Andersson <bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
>>> ---
>>> 
>>> Based on v4.11-rc3 with Arnd's Kconfig dependency fixes for BT_QCOMSMD
>>> (https://lkml.org/lkml/2017/3/20/1038).
>> 
>> Just some questions since I'm supposed to merge this into my net-next
>> tree.
>> 
>> What is the status of the Kconfig dependency fix and how will I be
>> getting it?
> 
> I acked that one separately and added you:
> 
> [PATCH v2] Bluetooth: btqcomsmd: fix compile-test dependency

I applied this to my 'net' tree, thanks.
