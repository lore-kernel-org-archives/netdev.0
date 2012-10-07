From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH] openvswitch: using nla_for_each_X to simplify the code
Date: Sun, 7 Oct 2012 11:30:51 -0700
Message-ID: <CAEP_g=_D1m+p0POKC5ozFEgfEhGzN9G_+Yja_iBz4guuRe6Nog@mail.gmail.com>
References: <CAPgLHd8hY-nZWaG-meEk1MtY5Rj_26Lj1bxH=jtn20jxni+U8g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: davem@davemloft.net, yongjun_wei@trendmicro.com.cn,
	dev@openvswitch.org, netdev@vger.kernel.org
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog116.obsmtp.com ([74.125.149.240]:47661 "HELO
	na3sys009aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752311Ab2JGSbM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Oct 2012 14:31:12 -0400
Received: by mail-ob0-f174.google.com with SMTP id uo13so3113490obb.19
        for <netdev@vger.kernel.org>; Sun, 07 Oct 2012 11:31:11 -0700 (PDT)
In-Reply-To: <CAPgLHd8hY-nZWaG-meEk1MtY5Rj_26Lj1bxH=jtn20jxni+U8g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 7, 2012 at 6:42 AM, Wei Yongjun <weiyj.lk@gmail.com> wrote:
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>
> Using nla_for_each_nested() or nla_for_each_attr()
> to simplify the code.
>
> dpatch engine is used to auto generate this patch.
> (https://github.com/weiyj/dpatch)
>
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

It is done this way intentionally to avoid checks on the fast path for
conditions that have already been validated.
