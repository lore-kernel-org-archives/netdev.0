From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH v2 net-next] net: make dev_set_mtu() honor notification
 return code
Date: Fri, 10 Jan 2014 17:21:17 +0100
Message-ID: <20140110162117.GB2501@minipsycho.brq.redhat.com>
References: <1389369385-17439-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f50.google.com ([74.125.83.50]:35769 "EHLO
	mail-ee0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751306AbaAJQVV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 11:21:21 -0500
Received: by mail-ee0-f50.google.com with SMTP id c41so1999448eek.23
        for <netdev@vger.kernel.org>; Fri, 10 Jan 2014 08:21:20 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1389369385-17439-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Jan 10, 2014 at 04:56:25PM CET, vfalico@redhat.com wrote:
>Currently, after changing the MTU for a device, dev_set_mtu() calls
>NETDEV_CHANGEMTU notification, however doesn't verify it's return code -
>which can be NOTIFY_BAD - i.e. some of the net notifier blocks refused this
>change, and continues nevertheless.
>
>To fix this, verify the return code, and if it's an error - then revert the
>MTU to the original one, notify again and pass the error code.
>
>CC: Jiri Pirko <jiri@resnulli.us>
>CC: "David S. Miller" <davem@davemloft.net>
>CC: Eric Dumazet <edumazet@google.com>
>CC: Alexander Duyck <alexander.h.duyck@intel.com>
>CC: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

Reviewed-by: Jiri Pirko <jiri@resnulli.us>
