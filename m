From: Jesse Gross <jesse@kernel.org>
Subject: Re: [PATCH net] vxlan: clear IFF_TX_SKB_SHARING
Date: Tue, 16 Feb 2016 16:04:33 -0800
Message-ID: <CAEh+42hjEfke5jgxWWQENWRn1G-uycar+n-8Y9EQ90Bv6OTgZA@mail.gmail.com>
References: <ad978a069caa3c84931b9f0eca7a268f9b459963.1455656611.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:51576 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933342AbcBQAEu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2016 19:04:50 -0500
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id 543FB202FF
	for <netdev@vger.kernel.org>; Wed, 17 Feb 2016 00:04:49 +0000 (UTC)
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id A280320268
	for <netdev@vger.kernel.org>; Wed, 17 Feb 2016 00:04:48 +0000 (UTC)
Received: by mail-qg0-f46.google.com with SMTP id y9so330593qgd.3
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 16:04:48 -0800 (PST)
In-Reply-To: <ad978a069caa3c84931b9f0eca7a268f9b459963.1455656611.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 16, 2016 at 1:16 PM, Jiri Benc <jbenc@redhat.com> wrote:
> ether_setup sets IFF_TX_SKB_SHARING but this is not supported by vxlan as it
> modifies the skb on xmit.
>
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Presumably this is something that should be done on all tunnels that
can carry Ethernet frames, right?
