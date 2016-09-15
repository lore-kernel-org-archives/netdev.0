From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH] nfp: fix error return code in nfp_net_netdev_open()
Date: Thu, 15 Sep 2016 08:43:22 +0100
Message-ID: <20160915084322.56b84d90@jkicinski-Precision-T1700>
References: <1473911107-8427-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        Simon Horman <simon.horman@netronome.com>,
        Wei Yongjun <weiyongjun1@huawei.com>,
        oss-drivers@netronome.com, netdev@vger.kernel.org
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:38362 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754112AbcIOHn1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 03:43:27 -0400
Received: by mail-wm0-f48.google.com with SMTP id 1so75373853wmz.1
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 00:43:27 -0700 (PDT)
In-Reply-To: <1473911107-8427-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 Sep 2016 03:45:07 +0000, Wei Yongjun wrote:
> From: Wei Yongjun <weiyongjun1@huawei.com>
> 
> Fix to return a negative error code from the error handling
> case instead of 0, as done elsewhere in this function.
> 
> Fixes: 73725d9dfd99 ("nfp: allocate ring SW structs dynamically")
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Acked-by: Jakub Kicinski <jakub.kicinski@netronome.com>

FWIW this is for net.  Thanks Wei!
