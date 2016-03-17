From: Leon Romanovsky <leon@leon.nu>
Subject: Re: [PATCH 1/3] infiniband: IB/hns: add Hisilicon RoCE support
Date: Thu, 17 Mar 2016 08:43:59 +0200
Message-ID: <20160317064359.GA25216@leon.nu>
References: <1457692631-9290-1-git-send-email-oulijun@huawei.com>
 <1457692631-9290-2-git-send-email-oulijun@huawei.com>
 <20160311104239.GD3931@nanopsycho.orion>
 <56E9340E.3040207@huawei.com>
 <20160316103638.GB2254@nanopsycho.orion>
Reply-To: leon@leon.nu
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: oulijun <oulijun@huawei.com>, dledford@redhat.com,
	sean.hefty@intel.com, hal.rosenstock@gmail.com,
	davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	jiri@mellanox.com, ogerlitz@mellanox.com,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, gongyangming@huawei.com,
	xiaokun@huawei.com, tangchaofei@huawei.com, haifeng.wei@huawei.com,
	yisen.zhuang@huawei.com, yankejian@huawei.com,
	lisheng011@huawei.com, charles.chenxin@huawei.com,
	linuxarm@huawei.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34670 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752042AbcCQGpU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2016 02:45:20 -0400
Received: by mail-wm0-f68.google.com with SMTP id p65so13081435wmp.1
        for <netdev@vger.kernel.org>; Wed, 16 Mar 2016 23:45:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160316103638.GB2254@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 16, 2016 at 11:36:38AM +0100, Jiri Pirko wrote:
> >so, I continue to have it.
> 
> I will continue to bash on your odd codingstyle. Please fix it!

Jiri,

Checkpatch errors is an easiest issue with this patch.

It is full of functions without use, unconnected macros and
if you replace "hsi" to name of other well known driver, you will get
same code :).

They need to redesign the whole driver before resubmission.

Thanks.
