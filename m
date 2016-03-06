From: Amir Vadai <amir@vadai.me>
Subject: Re: [PATCH net-next V2 03/10] net/sched: Macro instead of
 CONFIG_NET_CLS_ACT ifdef
Date: Sun, 6 Mar 2016 10:54:18 +0200
Message-ID: <20160306085418.GA3246@office.Home>
References: <1457016960-27832-1-git-send-email-amir@vadai.me>
 <1457016960-27832-4-git-send-email-amir@vadai.me>
 <CAM_iQpV-4On99wn7=kZQeem=xZy5SV2GnKuoORGD4uzQw=H47w@mail.gmail.com>
 <20160303195141.GA15037@office.Home>
 <CAM_iQpVDXoNrTq+51eYFQHXaztASsUP67wC3n3iCBDeeKf6QJA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34945 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751138AbcCFIur (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Mar 2016 03:50:47 -0500
Received: by mail-wm0-f65.google.com with SMTP id 1so5714909wmg.2
        for <netdev@vger.kernel.org>; Sun, 06 Mar 2016 00:50:47 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAM_iQpVDXoNrTq+51eYFQHXaztASsUP67wC3n3iCBDeeKf6QJA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 04, 2016 at 10:20:18AM -0800, Cong Wang wrote:
> On Thu, Mar 3, 2016 at 11:51 AM, Amir Vadai <amir@vadai.me> wrote:
> > On Thu, Mar 03, 2016 at 09:45:28AM -0800, Cong Wang wrote:
> >>
> >> So why?
> > The struct will not be used, and without exposing it, the compiler will
> > complain on code like I have in patch 9/10 ("net/mlx5e: Support offload
> > cls_flower with drop action"):
> >
> > static int parse_tc_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
> >                             u32 *action, u32 *flow_tag)
> 
> Why not make this a nop when CONFIG_NET_CLS_ACT is not set?

In V0 I did make it a nop. Jiri has suggested [1] that I will replace
the ifdefs with the macro's tc_for_each_action and is_tcf_gact_shot. And
I do think it looks more elegant.

Why do you think it is a problem to expose truct tc_action?

Thanks for your review,
Amir

[1] - https://patchwork.ozlabs.org/patch/590550/
