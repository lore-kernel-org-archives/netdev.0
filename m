From: Bjorn Andersson <bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 1/3] soc: qcom: smd: Transition client drivers from smd
 to rpmsg
Date: Wed, 22 Mar 2017 14:57:33 -0700
Message-ID: <20170322215733.GH20094@minitux>
References: <20170320233544.1656-1-bjorn.andersson@linaro.org>
 <20170322.114439.679826829857326050.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org, gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org, johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        k.eugene.e-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, andy.gross-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org,
        david.brown-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org,
        linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        wcn36xx-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-msm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-soc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170322.114439.679826829857326050.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed 22 Mar 11:44 PDT 2017, David Miller wrote:

> From: Bjorn Andersson <bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
> Date: Mon, 20 Mar 2017 16:35:42 -0700
> 
> > By moving these client drivers to use RPMSG instead of the direct SMD
> > API we can reuse them ontop of the newly added GLINK wire-protocol
> > support found in the 820 and 835 Qualcomm platforms.
> > 
> > As the new (RPMSG-based) and old SMD implementations are mutually
> > exclusive we have to change all client drivers in one commit, to make
> > sure we have a working system before and after this transition.
> > 
> > Signed-off-by: Bjorn Andersson <bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
> > ---
> > 
> > Based on v4.11-rc3 with Arnd's Kconfig dependency fixes for BT_QCOMSMD
> > (https://lkml.org/lkml/2017/3/20/1038).
> 
> Just some questions since I'm supposed to merge this into my net-next
> tree.
> 
> What is the status of the Kconfig dependency fix and how will I be
> getting it?
> 

There are two Kconfig dependencies in play here, the first is
c3104aae5d8c ("remoteproc: qcom: fix QCOM_SMD dependencies"), this was
picked up by Linus yesterday and will as such be in v4.10-rc4.

The other dependency, is the one Marcel wants you to pick up here is
https://patchwork.kernel.org/patch/9635385/. It's on LKML, but if you
want I can resend it with you as direct recipient, with Marcel's ack.

Likely Arnd would like this fix to be sent upstream for v4.11 already.

> Second, should I merge all three of these patches to net-next or just
> this one?
> 

I would like all three to be merged in this cycle and in addition I have
a couple of patches coming up that will cause some minor conflicts with
patch 2 - so I would prefer if patch 2 was available in a tag I can
merge into my tree.

Would it be possible for you to prepare merge all 4 (these 3 and the
bluetooth fix) and prepare a tag for Andy, Marcel and myself to include
in our trees?

Regards,
Bjorn
