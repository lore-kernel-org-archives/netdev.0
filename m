From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 2/2] net: Add Qualcomm IPC router
Date: Thu, 28 Apr 2016 17:19:16 -0400 (EDT)
Message-ID: <20160428.171916.1050345640446701577.davem@davemloft.net>
References: <1461784383-2978-1-git-send-email-bjorn.andersson@linaro.org>
	<1461784383-2978-2-git-send-email-bjorn.andersson@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andy.gross@linaro.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-arm-msm@vger.kernel.org,
	courtney.cavin@sonymobile.com, bjorn.andersson@sonymobile.com
To: bjorn.andersson@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461784383-2978-2-git-send-email-bjorn.andersson@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bjorn Andersson <bjorn.andersson@linaro.org>
Date: Wed, 27 Apr 2016 12:13:03 -0700

> From: Courtney Cavin <courtney.cavin@sonymobile.com>
> 
> Add an implementation of Qualcomm's IPC router protocol, used to
> communicate with service providing remote processors.
> 
> Signed-off-by: Courtney Cavin <courtney.cavin@sonymobile.com>
> Signed-off-by: Bjorn Andersson <bjorn.andersson@sonymobile.com>
> [bjorn: Cope with 0 being a valid node id and implement RTM_NEWADDR]
> Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
> ---
> 
> Changes since v2:
> - Altered Kconfig dependency for QRTR_SMD to be compile testable
> 
> Changes since v1:
> - Made node 0 (normally the Qualcomm modem) a valid node
> - Implemented RTM_NEWADDR for specifying the local node id

Please adjust this so that CONFIG_QRTR can be modular.
