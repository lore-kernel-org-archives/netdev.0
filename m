From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next] vxlan: expose COLLECT_METADATA flag to user space
Date: Mon, 3 Aug 2015 14:14:18 -0700
Message-ID: <CAEP_g=-7-PkYGdcigXC68nh+nCKHkr=9soYjcQsCx5rOkTQ90Q@mail.gmail.com>
References: <1438312222-7130-1-git-send-email-ast@plumgrid.com>
 <20150731080019.GB4738@pox.localdomain> <55BB9734.1010005@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Graf <tgraf@suug.ch>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	netdev <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:33517 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932358AbbHCVOj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2015 17:14:39 -0400
Received: by lbbyj8 with SMTP id yj8so84550606lbb.0
        for <netdev@vger.kernel.org>; Mon, 03 Aug 2015 14:14:37 -0700 (PDT)
In-Reply-To: <55BB9734.1010005@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 31, 2015 at 8:41 AM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> thanks. I think exposing collect_metadata for vxlan and in the future
> for other tunnel types is the clean enough way, though the other
> alternative would be to get rid of collect_metadata flag
> from the kernel and do it when flowmode flag is set. Thoughts?

This seems like a good idea to me - I'm not sure that flow based
tunnels are all that useful without metadata collection enabled and
the fewer interfaces that we have to create for each tunnel type, the
better.
