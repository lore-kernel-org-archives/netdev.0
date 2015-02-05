From: Thomas Graf <tgraf@noironetworks.com>
Subject: Re: [ovs-dev] [RFC: add openvswitch actions using BPF 2/9] odp: add
 a new ODP action: OVS_ACTION_ATTR_BPF_PROG
Date: Thu, 5 Feb 2015 15:11:43 +0100
Message-ID: <20150205141143.GC5546@pox.localdomain>
References: <1423090163-19902-1-git-send-email-azhou@nicira.com>
 <1423090163-19902-3-git-send-email-azhou@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dev@openvswitch.com, netdev@vger.kernel.org
To: Andy Zhou <azhou@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f178.google.com ([74.125.82.178]:38033 "EHLO
	mail-we0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757432AbbBEOLq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 09:11:46 -0500
Received: by mail-we0-f178.google.com with SMTP id k48so7869487wev.9
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 06:11:45 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1423090163-19902-3-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/04/15 at 02:49pm, Andy Zhou wrote:
> +struct ovs_action_bpf_prog {
> +	__be32 prog_fd;
> +	__be32 arg0;
> +	__be32 arg1;
> +};

Given the 64 bit registers of BPF. Should we have all args in the
Netlink message be 64 bit as well?
