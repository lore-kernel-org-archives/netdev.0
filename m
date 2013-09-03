From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Subject: RE: [patch] qlcnic: remove a stray semicolon
Date: Tue, 3 Sep 2013 16:43:59 +0000
Message-ID: <ADFE82A996F10145934E45547759F763311D56C3@avmb3.qlogic.org>
References: <20130903091347.GA4630@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Rajesh Borundia <rajesh.borundia@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>,
	Dept-Eng Linux Driver <Linux-Driver@qlogic.com>,
	netdev <netdev@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20130903091347.GA4630@elgon.mountain>
Content-Language: en-US
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> -----Original Message-----
> From: Dan Carpenter [mailto:dan.carpenter@oracle.com]
> Sent: Tuesday, September 03, 2013 2:14 AM
> To: Himanshu Madhani
> Cc: Rajesh Borundia; Shahed Shaikh; Jitendra Kalsaria; Sony Chacko; Sucheta
> Chakraborty; Dept-Eng Linux Driver; netdev; kernel-janitors@vger.kernel.org
> Subject: [patch] qlcnic: remove a stray semicolon
> 
> Just remove a small semicolon.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
> b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
> index 332aa71..4d7ad00 100644
> --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
> +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
> @@ -1709,7 +1709,7 @@ qlcnic_set_dump(struct net_device *netdev, struct
> ethtool_dump *val)
>  		qlcnic_dev_request_reset(adapter, val->flag);
>  		adapter->flags &= ~QLCNIC_FW_RESET_OWNER;
>  		break;
> -;
> +
>  	case QLCNIC_SET_QUIESCENT:
>  	case QLCNIC_RESET_QUIESCENT:
>  		state = QLC_SHARED_REG_RD32(adapter,
> QLCNIC_CRB_DEV_STATE);

Thanks

Acked-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
