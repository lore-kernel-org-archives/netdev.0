From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCHv2 net] openvswitch: Scrub skb between namespaces
Date: Sat, 17 Oct 2015 09:55:44 +0200
Message-ID: <20151017075544.GE13981@pox.localdomain>
References: <1445018901-18839-1-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, pshelar@nicira.com, hannes@redhat.com,
	jesse@nicira.com
To: Joe Stringer <joestringer@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:35349 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751066AbbJQHzq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Oct 2015 03:55:46 -0400
Received: by wicll6 with SMTP id ll6so36084124wic.0
        for <netdev@vger.kernel.org>; Sat, 17 Oct 2015 00:55:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1445018901-18839-1-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/16/15 at 11:08am, Joe Stringer wrote:
> If OVS receives a packet from another namespace, then the packet should
> be scrubbed. However, people have already begun to rely on the behaviour
> that skb->mark is preserved across namespaces, so retain this one field.
> 
> This is mainly to address information leakage between namespaces when
> using OVS internal ports, but by placing it in ovs_vport_receive() it is
> more generally applicable, meaning it should not be overlooked if other
> port types are allowed to be moved into namespaces in future.
> 
> Signed-off-by: Joe Stringer <joestringer@nicira.com>

Perfect, thanks!

Acked-by: Thomas Graf <tgraf@suug.ch>
