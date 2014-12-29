From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH/RFC flow-net-next 02/10] net: flow: Add features to tables
Date: Mon, 29 Dec 2014 15:03:39 -0800
Message-ID: <CAHA+R7NmfUpYcKfW_Gck2HaANH3OQk-9BAYZCXnBtGO1eV13xg@mail.gmail.com>
References: <1419819340-19000-1-git-send-email-simon.horman@netronome.com>
	<1419819340-19000-3-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f52.google.com ([209.85.192.52]:49080 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751534AbaL2XDk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Dec 2014 18:03:40 -0500
Received: by mail-qg0-f52.google.com with SMTP id a108so9651050qge.25
        for <netdev@vger.kernel.org>; Mon, 29 Dec 2014 15:03:40 -0800 (PST)
In-Reply-To: <1419819340-19000-3-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 28, 2014 at 6:15 PM, Simon Horman
<simon.horman@netronome.com> wrote:
> +static struct net_flow_table *net_flow_table_get_table(struct net_device *dev,
> +                                                      int table_uid)
> +{
> +       struct net_flow_table **tables;
> +       int i;
> +
> +       tables = net_flow_get_tables(dev);
> +       if (IS_ERR(tables))
> +               return ERR_PTR(PTR_ERR(tables));

Seriously? :)
