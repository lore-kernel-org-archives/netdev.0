From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCHv2 net] openvswitch: Scrub skb between namespaces
Date: Fri, 16 Oct 2015 11:47:01 -0700
Message-ID: <CALnjE+prPFWDjbnXoy_vp7+X2X2DnPJp0DLOcxnZkCK1AExa8A@mail.gmail.com>
References: <1445018901-18839-1-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Thomas Graf <tgraf@suug.ch>,
	Hannes Sowa <hannes@redhat.com>, Jesse Gross <jesse@nicira.com>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:34155 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753580AbbJPSrC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 14:47:02 -0400
Received: by igbni9 with SMTP id ni9so19793248igb.1
        for <netdev@vger.kernel.org>; Fri, 16 Oct 2015 11:47:01 -0700 (PDT)
In-Reply-To: <1445018901-18839-1-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 16, 2015 at 11:08 AM, Joe Stringer <joestringer@nicira.com> wrote:
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

Acked-by: Pravin B Shelar <pshelar@nicira.com>
