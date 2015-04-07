From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [RFC PATCH net-next] switchdev: fdb add/del via swdev obj.
Date: Mon, 6 Apr 2015 22:16:49 -0700
Message-ID: <CAE4R7bBjPNs40cQfYGEueHVnP-_gT7gX41i=NjZmFt7R_XhLSg@mail.gmail.com>
References: <1428362710-20815-1-git-send-email-sridhar.samudrala@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Scott Feldman <sfeldman@gmail.com>, Netdev <netdev@vger.kernel.org>
To: Sridhar Samudrala <sridhar.samudrala@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f172.google.com ([209.85.220.172]:35040 "EHLO
	mail-qk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750912AbbDGFQu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 01:16:50 -0400
Received: by qkhg7 with SMTP id g7so41312619qkh.2
        for <netdev@vger.kernel.org>; Mon, 06 Apr 2015 22:16:49 -0700 (PDT)
In-Reply-To: <1428362710-20815-1-git-send-email-sridhar.samudrala@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 6, 2015 at 4:25 PM, Sridhar Samudrala
<sridhar.samudrala@intel.com> wrote:
> This is a patch on top of Scott's v3 version of switchdev spring
> cleanup patches.
>
> Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>

Sridhar,

You patch is spot-on.  We can't apply it yet until my stuff gets
in...I'm working on it.  I extended your patch for fdb dump as well,
which I'll send tomorrow.  For dump, I've added swdev_port_obj_dump()
op and moved all the netlink skb building code to code swdev code.
The driver implements very little and is unaware of the netlink msg
being built.

With your patch, we can finally do the fdb flushes and fdb ageing on
the port without having to synthesis netlink msgs inside the kernel.
I'm not sure if that's what you're working on, but it's the next
logical piece to plumb.  (Hopefully you are working on that :).

(btw, you have my email addr wrong).

Acked-in-spirit-by: Scott Feldman <sfeldma@gmail.com>

-scott
