From: Ani Sinha <ani@aristanetworks.com>
Subject: Re: [PATCH net 1/2] net: dev_queue_xmit_nit: fix skb->vlan_tci field value
Date: Tue, 8 Jan 2013 11:54:49 -0800
Message-ID: <CAOxq_8O4+g4=r6QDRjxAjOTwy1wmqSMuFggrjdpDwFmoFUY4sw@mail.gmail.com>
References: <1357671093-9605-1-git-send-email-dborkman@redhat.com>
	<1357671093-9605-2-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jiri Pirko <jpirko@redhat.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f177.google.com ([209.85.210.177]:36015 "EHLO
	mail-ia0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756140Ab3AHTyu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 14:54:50 -0500
Received: by mail-ia0-f177.google.com with SMTP id h8so121109iaa.8
        for <netdev@vger.kernel.org>; Tue, 08 Jan 2013 11:54:50 -0800 (PST)
In-Reply-To: <1357671093-9605-2-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Agreed with the fix. This fixes the issue introduced by this change :l


On Tue, Jan 8, 2013 at 10:51 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
> VLAN packets that are locally injected through taps will loose their
> skb->vlan_tci value when they pass dev_hard_start_xmit and get looped
> back to a packet sniffer via dev_queue_xmit_nit. Besides others, this
> meta data is used in Linux socket filtering for VLANs. Tested with a
> VLAN ancillary ops filter.
>
> Patch is based on a previous version by Jiri Pirko.
>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Ani Sinha <ani@aristanetworks.com>
> Cc: Jiri Pirko <jpirko@redhat.com>
> Reported-by: Paul Pearce <pearce@cs.berkeley.edu>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Acked-by: Ani Sinha <ani@aristanetworks.com>
