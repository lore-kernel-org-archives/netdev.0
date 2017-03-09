From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] team: use ETH_MAX_MTU as max mtu
Date: Wed, 08 Mar 2017 22:20:00 -0800 (PST)
Message-ID: <20170308.222000.2114880882228056038.davem@davemloft.net>
References: <20170306134858.2096-1-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, xiyou.wangcong@gmail.com,
        jiri@resnulli.us, netdev@vger.kernel.org
To: jarod@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170306134858.2096-1-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jarod Wilson <jarod@redhat.com>
Date: Mon,  6 Mar 2017 08:48:58 -0500

> This restores the ability to set a team device's mtu to anything higher
> than 1500. Similar to the reported issue with bonding, the team driver
> calls ether_setup(), which sets an initial max_mtu of 1500, while the
> underlying hardware can handle something much larger. Just set it to
> ETH_MAX_MTU to support all possible values, and the limitations of the
> underlying devices will prevent setting anything too large.
> 
> Fixes: 91572088e3fd ("net: use core MTU range checking in core net infra")
> CC: Cong Wang <xiyou.wangcong@gmail.com>
> CC: Jiri Pirko <jiri@resnulli.us>
> CC: netdev@vger.kernel.org
> Signed-off-by: Jarod Wilson <jarod@redhat.com>

Applied and queued up for -stable, thanks.
