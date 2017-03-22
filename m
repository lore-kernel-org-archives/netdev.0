From: Andy Gross <andy.gross@linaro.org>
Subject: Re: [PATCH 1/3] soc: qcom: smd: Transition client drivers from smd
 to rpmsg
Date: Wed, 22 Mar 2017 16:56:27 -0500
Message-ID: <20170322215627.GD22585@hector.attlocal.net>
References: <20170320233544.1656-1-bjorn.andersson@linaro.org>
 <20170322.114439.679826829857326050.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bjorn.andersson@linaro.org, marcel@holtmann.org,
        gustavo@padovan.org, johan.hedberg@gmail.com, k.eugene.e@gmail.com,
        kvalo@codeaurora.org, david.brown@linaro.org, arnd@arndb.de,
        linux-bluetooth@vger.kernel.org, linux-kernel@vger.kernel.org,
        wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-arm-msm@vger.kernel.org,
        linux-soc@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170322.114439.679826829857326050.davem@davemloft.net>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 22, 2017 at 11:44:39AM -0700, David Miller wrote:
> From: Bjorn Andersson <bjorn.andersson@linaro.org>
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
> > Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
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
> Second, should I merge all three of these patches to net-next or just
> this one?

David,
I ack'd all three.  Please take these through your tree.


Bjorn,
Are we going to need an immutable branch or tag for sychronizing work?

Regards,

Andy Gross
