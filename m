From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCHv3 net 1/3] openvswitch: Fix double-free on ip_defrag() errors
Date: Tue, 27 Oct 2015 14:29:38 -0700
Message-ID: <CALnjE+qCAsSyQVDm4Q9A4bW+ZhBnLy1p-vGyicDhBbnakOwE5Q@mail.gmail.com>
References: <1445829710-11292-1-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Florian Westphal <fw@strlen.de>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Andy Zhou <azhou@nicira.com>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:36053 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750877AbbJ0V3i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 17:29:38 -0400
Received: by igdg1 with SMTP id g1so93267099igd.1
        for <netdev@vger.kernel.org>; Tue, 27 Oct 2015 14:29:38 -0700 (PDT)
In-Reply-To: <1445829710-11292-1-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 25, 2015 at 8:21 PM, Joe Stringer <joestringer@nicira.com> wrote:
> If ip_defrag() returns an error other than -EINPROGRESS, then the skb is
> freed. When handle_fragments() passes this back up to
> do_execute_actions(), it will be freed again. Prevent this double free
> by never freeing the skb in do_execute_actions() for errors returned by
> ovs_ct_execute. Always free it in ovs_ct_execute() error paths instead.
>
> Fixes: 7f8a436eaa2c ("openvswitch: Add conntrack action")
> Reported-by: Florian Westphal <fw@strlen.de>
> Signed-off-by: Joe Stringer <joestringer@nicira.com>

Acked-by: Pravin B Shelar <pshelar@nicira.com>
