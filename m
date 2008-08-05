From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [PATCH]&[Question] netdevice: Use netdev_priv()
Date: Tue, 5 Aug 2008 10:51:49 -0700
Message-ID: <200808051051.49824.divy@chelsio.com>
References: <4892E6EC.3040201@cn.fujitsu.com> <4898238F.1050105@cn.fujitsu.com> <20080805.030433.100665376.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: wangchen@cn.fujitsu.com, netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:11050 "EHLO
	stargate.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1758971AbYHERvy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2008 13:51:54 -0400
In-Reply-To: <20080805.030433.100665376.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 05 August 2008 03:04:33 am David Miller wrote:
> From: Wang Chen <wangchen@cn.fujitsu.com>
> Date: Tue, 05 Aug 2008 17:55:27 +0800
>
> > init_one() of cxgb2 makes several net_device to share one private data.
> > For this purpose, direct reference is necessary.
>
> It should use netdev->ml_priv which is created for this purpose.
>
> Every direct netdev->priv usage is a bug.

cxgb3 was fixed in this regard, cxgb2 needs the same treatment ...

cheers,
Divy
