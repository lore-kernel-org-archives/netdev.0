From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next 1/4] net_sched: act: clean up notification functions
Date: Wed, 18 Dec 2013 16:48:50 -0800
Message-ID: <CAM_iQpV9Z_K7DRrYLF+hO=_nqEWYoEstuEEGunG1knXe_KB-DQ@mail.gmail.com>
References: <1387413403-6395-1-git-send-email-xiyou.wangcong@gmail.com>
	<1387413403-6395-2-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:58294 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752771Ab3LSAsv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 19:48:51 -0500
Received: by mail-ob0-f178.google.com with SMTP id uz6so458567obc.37
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 16:48:50 -0800 (PST)
In-Reply-To: <1387413403-6395-2-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 18, 2013 at 4:36 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> -               if (ret > 0)
> -                       return 0;
> -               return ret;
> -       }
> +       else /* delete */
> +               ret = tcf_del_notify(net, n, &actions, portid);

This piece doesn't look correct. :-) I will fix it.
