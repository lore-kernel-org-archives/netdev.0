From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH -next] rocker: fix error return code in
 rocker_world_check_init()
Date: Sat, 22 Oct 2016 17:34:29 +0200
Message-ID: <20161022153429.GA3657@nanopsycho.orion>
References: <1477146666-29671-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org,
        davem@davemloft.net
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34130 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938626AbcJVPec (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Oct 2016 11:34:32 -0400
Received: by mail-wm0-f68.google.com with SMTP id d199so3088841wmd.1
        for <netdev@vger.kernel.org>; Sat, 22 Oct 2016 08:34:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1477146666-29671-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Oct 22, 2016 at 04:31:06PM CEST, weiyj.lk@gmail.com wrote:
>From: Wei Yongjun <weiyongjun1@huawei.com>
>
>Fix to return error code -EINVAL from the error handling
>case instead of 0, as done elsewhere in this function.
>
>Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Fixes: e420114eef4a ("rocker: introduce worlds infrastructure")
Acked-by: Jiri Pirko <jiri@mellanox.com>

Dave, you can queue this to -net.
