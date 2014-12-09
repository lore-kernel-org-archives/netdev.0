From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [bisect] 3.18 oops in tcp_v4_send_reset()
Date: Tue, 09 Dec 2014 08:18:34 -0800
Message-ID: <1418141914.14835.21.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141209160023.GA31520@fluid.dannf>
	 <1418141783.14835.20.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	"David S. Miller" <davem@davemloft.net>
To: dann frazier <dann.frazier@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:56786 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932484AbaLIQSh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 11:18:37 -0500
Received: by mail-ie0-f177.google.com with SMTP id rd18so800783iec.36
        for <netdev@vger.kernel.org>; Tue, 09 Dec 2014 08:18:36 -0800 (PST)
In-Reply-To: <1418141783.14835.20.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-12-09 at 08:16 -0800, Eric Dumazet wrote:
> On Tue, 2014-12-09 at 09:00 -0700, dann frazier wrote:
> > I'm observing a very reproducible oops which I have bisected down to
> > commit ca777ef:

> 
> Following patch should have fixed this 
> 
> http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=c3658e8d0f10147fc86018be7f11668246c156d3
> 

Oh well, fix was not complete. I'll submit a followup patch.
