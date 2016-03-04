From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next V2 03/10] net/sched: Macro instead of
 CONFIG_NET_CLS_ACT ifdef
Date: Fri, 4 Mar 2016 10:20:18 -0800
Message-ID: <CAM_iQpVDXoNrTq+51eYFQHXaztASsUP67wC3n3iCBDeeKf6QJA@mail.gmail.com>
References: <1457016960-27832-1-git-send-email-amir@vadai.me>
	<1457016960-27832-4-git-send-email-amir@vadai.me>
	<CAM_iQpV-4On99wn7=kZQeem=xZy5SV2GnKuoORGD4uzQw=H47w@mail.gmail.com>
	<20160303195141.GA15037@office.Home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>
To: Amir Vadai <amir@vadai.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f178.google.com ([209.85.161.178]:34278 "EHLO
	mail-yw0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759525AbcCDSUT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 13:20:19 -0500
Received: by mail-yw0-f178.google.com with SMTP id h129so51079048ywb.1
        for <netdev@vger.kernel.org>; Fri, 04 Mar 2016 10:20:18 -0800 (PST)
In-Reply-To: <20160303195141.GA15037@office.Home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 3, 2016 at 11:51 AM, Amir Vadai <amir@vadai.me> wrote:
> On Thu, Mar 03, 2016 at 09:45:28AM -0800, Cong Wang wrote:
>>
>> So why?
> The struct will not be used, and without exposing it, the compiler will
> complain on code like I have in patch 9/10 ("net/mlx5e: Support offload
> cls_flower with drop action"):
>
> static int parse_tc_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
>                             u32 *action, u32 *flow_tag)

Why not make this a nop when CONFIG_NET_CLS_ACT is not set?
