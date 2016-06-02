From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/5] fsl/qe: setup clock source for TDM mode
Date: Thu, 02 Jun 2016 12:24:51 -0700 (PDT)
Message-ID: <20160602.122451.160749876120675817.davem@davemloft.net>
References: <1464831901-15913-1-git-send-email-qiang.zhao@nxp.com>
	<1464831901-15913-2-git-send-email-qiang.zhao@nxp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oss@buserror.net, linuxppc-dev@lists.ozlabs.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	xiaobo.xie@nxp.com
To: qiang.zhao@nxp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464831901-15913-2-git-send-email-qiang.zhao@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zhao Qiang <qiang.zhao@nxp.com>
Date: Thu, 2 Jun 2016 09:44:58 +0800

> +static int ucc_get_tdm_sync_source(u32 tdm_num, enum qe_clock clock,
> +				   enum comm_dir mode)
> +{
> +	int source = -EINVAL;
> +
> +	if (mode == COMM_DIR_RX && clock == QE_RSYNC_PIN) {
> +		source = 0;
> +		return source;
> +	}
> +	if (mode == COMM_DIR_TX && clock == QE_TSYNC_PIN) {
> +		source = 0;
> +		return source;
> +	}
> +
> +	switch (tdm_num) {
> +	case 0:
> +	case 1:
> +		switch (clock) {
> +		case QE_BRG9:
> +				source = 1;
> +				break;
> +		case QE_BRG10:
> +				source = 2;
> +				break;

These switch case bodies are over indented.  Same goes for the rest of
this function.
