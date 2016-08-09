From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] ravb: add sleep PM suspend/resume support
Date: Tue, 09 Aug 2016 16:16:36 -0700 (PDT)
Message-ID: <20160809.161636.2181233072433514866.davem@davemloft.net>
References: <20160803135647.23242-1-niklas.soderlund+renesas@ragnatech.se>
	<20160803135647.23242-3-niklas.soderlund+renesas@ragnatech.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
	sergei.shtylyov@cogentembedded.com, wsa@the-dreams.de
To: niklas.soderlund+renesas@ragnatech.se
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <20160803135647.23242-3-niklas.soderlund+renesas@ragnatech.se>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Niklas Söderlund <niklas.soderlund+renesas@ragnatech.se>
Date: Wed,  3 Aug 2016 15:56:47 +0200

> The interface would not function after the system had been woken up
> after have been suspended (echo mem > /sys/power/state) cycle. The
> reason for this is that all device registers have been reset to its
> default values. This patch adds sleep suspend and resume functions that
> detached the interface at suspend and restore the registers and reattach
> the interface at resume.
> 
> Only the registers that are only configured at probe time needs to be
> explicitly restored by the resume handler. All other registers are
> reconfigured by either reopening the device in the resume handler (if
> the device was running when the system was suspended) or when the
> interface is opened by a user at a later time.
> 
> Signed-off-by: Niklas Söderlund <niklas.soderlund+renesas@ragnatech.se>

Applied to net-next, thanks.
