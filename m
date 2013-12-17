From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2 net-next] net: vxlan: use custom ndo_change_mtu
 handler
Date: Tue, 17 Dec 2013 13:57:03 -0800
Message-ID: <20131217135703.256f0e28@nehalam.linuxnetplumber.net>
References: <1387312660-3467-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, shahed.shaikh@qlogic.com,
	netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:63308 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754016Ab3LQV5G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 16:57:06 -0500
Received: by mail-pa0-f42.google.com with SMTP id lj1so5036840pab.15
        for <netdev@vger.kernel.org>; Tue, 17 Dec 2013 13:57:06 -0800 (PST)
In-Reply-To: <1387312660-3467-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 17 Dec 2013 21:37:40 +0100
Daniel Borkmann <dborkman@redhat.com> wrote:

> +	struct vxlan_rdst *dst = &vxlan->default_dst;

This line is defined by never used.
