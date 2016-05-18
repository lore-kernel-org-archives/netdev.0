From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: QRTR merge conflict resolution
Date: Wed, 18 May 2016 10:43:20 +1000
Message-ID: <20160518104320.23ae8557@canb.auug.org.au>
References: <20160510183934.GJ1256@tuxbot>
	<2606282.lG9qK7uBW0@wuerfel>
	<20160513221909.GC1256@tuxbot>
	<20160517.141154.1511755950068252376.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bjorn.andersson@linaro.org, arnd@arndb.de,
	linux-arm-kernel@lists.infradead.org, andy.gross@linaro.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-next@vger.kernel.org, olof@lixom.net
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160517.141154.1511755950068252376.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

On Tue, 17 May 2016 14:11:54 -0400 (EDT) David Miller <davem@davemloft.net> wrote:
>
> From: Bjorn Andersson <bjorn.andersson@linaro.org>
> Date: Fri, 13 May 2016 15:19:09 -0700
> 
> > I have prepared the merge of net-next and the conflicting tag from the
> > Qualcomm SOC, please include this in your pull towards Linus to avoid
> > the merge conflict.  
> 
> Pulled, thanks.

Except in the merge resolution, the 2 new functions added to
include/linux/soc/qcom/smd.h (qcom_smd_get_drvdata and
qcom_smd_set_drvdata) were not marked "static inline" :-(

-- 
Cheers,
Stephen Rothwell
