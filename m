From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next V2 0/3] net/sched: act_pedit: Use offset
 relative to conventional network headers
Date: Thu, 5 Jan 2017 13:44:39 +0100
Message-ID: <20170105134439.5b31678f@griffin>
References: <20170105095454.32644-1-amir@vadai.me>
        <20170105125414.5640b1b8@griffin>
        <20170105123458.GA2361@office.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Jiri Pirko <jiri@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>
To: Amir Vadai <amir@vadai.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60840 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751650AbdAEMon (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 5 Jan 2017 07:44:43 -0500
In-Reply-To: <20170105123458.GA2361@office.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 5 Jan 2017 14:34:58 +0200, Amir Vadai wrote:
> This is a simple action. It is not fool proof - it prevents the user
> from getting out of packet bounds, but it is the user responsibility to
> provide valid rules.

I think I can live with that. Just wanted to point that out. Especially
with combination with hardware offload (e.g. the hardware should not
hang or reset on that).

 Jiri
