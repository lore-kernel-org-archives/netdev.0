From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH 1/2] bnx2x:Fix error handling in the function
 bnxc2x_dbcx_set_params
Date: Sun, 19 Jul 2015 12:25:36 +0000
Message-ID: <B5657A6538887040AD3A81F1008BEC63DEBF6C@avmb3.qlogic.org>
References: <1437225397-26079-1-git-send-email-xerofoify@gmail.com>
 <B5657A6538887040AD3A81F1008BEC63DEB75E@avmb3.qlogic.org>
 <55AB9673.7060704@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: nick <xerofoify@gmail.com>, Ariel Elior <Ariel.Elior@qlogic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55AB9673.7060704@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I am used to sending out one patch per each fix like this for each function.
> If you don't like me doing this I don't when sending patches for your
> subsystem(s).

I think that would be preferable.

> In addition would something like this fix your complains about not fixing error
> handling in bnx2x_dcbnl_update_applist.
> int bnx2x_dcbnl_update_applist(struct bnx2x *bp, bool delall) {
>  	int i, err = 0;
> 
>  	for (i = 0; i < DCBX_MAX_APP_PROTOCOL && err == 0; i++) {
...
> 				err = dcb_setapp(bp->dev, &app);
> +				if (err)
> +					break;

Well, either that or retain the fact there's an error and return it at the end.
