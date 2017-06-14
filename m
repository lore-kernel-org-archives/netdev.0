From: Amir Vadai <amir@vadai.me>
Subject: Re: [PATCH net] net/act_pedit: fix an error code
Date: Wed, 14 Jun 2017 16:20:42 +0300
Message-ID: <20170614131846.GA2955@office.localdomain>
References: <20170614102930.GH29394@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:33308 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752438AbdFNNUE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 09:20:04 -0400
Content-Disposition: inline
In-Reply-To: <20170614102930.GH29394@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 14, 2017 at 01:29:31PM +0300, Dan Carpenter wrote:
> I'm reviewing static checker warnings where we do ERR_PTR(0), which is
> the same as NULL.  I'm pretty sure we intended to return ERR_PTR(-EINVAL)
> here.  Sometimes these bugs lead to a NULL dereference but I don't
> immediately see that problem here.
> 
> Fixes: 71d0ed7079df ("net/act_pedit: Support using offset relative to the conventional network headers")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
You are right, it was intended to be -EINVAL. Thanks.

Acked-by: Amir Vadai <amir@vadai.me>
