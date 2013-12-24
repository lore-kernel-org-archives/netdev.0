From: Neal Cardwell <ncardwell@google.com>
Subject: Re: 3.13-rc4: lockdep warning in network stack
Date: Tue, 24 Dec 2013 12:55:36 -0500
Message-ID: <CADVnQykeb8CUXxSxm5OYS2vz1XvMWz3=GObLw1ACb_P_XZ_tQg@mail.gmail.com>
References: <52B9794C.8040506@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Arend van Spriel <arend@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f48.google.com ([74.125.83.48]:49881 "EHLO
	mail-ee0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752329Ab3LXRzh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Dec 2013 12:55:37 -0500
Received: by mail-ee0-f48.google.com with SMTP id e49so2961982eek.35
        for <netdev@vger.kernel.org>; Tue, 24 Dec 2013 09:55:36 -0800 (PST)
In-Reply-To: <52B9794C.8040506@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 24, 2013 at 7:08 AM, Arend van Spriel <arend@broadcom.com> wrote:
> Hi David,
>
> Noticed this lockdep warning. As rc4 is already out for a while it may
> already be known. It happened upon initial login, but that may have been
> a coincidence. Attached are the dmesg output and the kernel configuration.

Yes, this should be fixed in Linux 3.13-rc5 with:

  e47eb5d udp: ipv4: do not use sk_dst_lock from softirq context

neal
