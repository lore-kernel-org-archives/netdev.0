From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next 6/6] geneve: Remove duplicate dev list
Date: Wed, 12 Aug 2015 15:07:45 -0700
Message-ID: <CAEP_g=_JjWn6uj+bvaLu=GzemjeSnHSKEtyzGjRvOv5r_CoU5w@mail.gmail.com>
References: <1439356678-21874-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:34290 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751297AbbHLWIG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 18:08:06 -0400
Received: by lbbtg9 with SMTP id tg9so17455250lbb.1
        for <netdev@vger.kernel.org>; Wed, 12 Aug 2015 15:08:04 -0700 (PDT)
In-Reply-To: <1439356678-21874-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 11, 2015 at 10:17 PM, Pravin B Shelar <pshelar@nicira.com> wrote:
>  static void __net_exit geneve_exit_net(struct net *net)
>  {
>         struct geneve_net *gn = net_generic(net, geneve_net_id);
> -       struct geneve_dev *geneve, *next;
> +       struct hlist_head *vni_list_head;
> +       struct hlist_node *next;
>         struct net_device *dev, *aux;
> +       struct geneve_dev *geneve;

I think these newly added variables could be inside the VNI_HASH_SIZE loop.

Reviewed-by: Jesse Gross <jesse@nicira.com>
