From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net] team: use ETH_MAX_MTU as max mtu
Date: Mon, 6 Mar 2017 14:54:36 +0100
Message-ID: <20170306135436.GD1822@nanopsycho.orion>
References: <20170306134858.2096-1-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Cong Wang <xiyou.wangcong@gmail.com>,
        netdev@vger.kernel.org
To: Jarod Wilson <jarod@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170306134858.2096-1-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mon, Mar 06, 2017 at 02:48:58PM CET, jarod@redhat.com wrote:
>This restores the ability to set a team device's mtu to anything higher
>than 1500. Similar to the reported issue with bonding, the team driver
>calls ether_setup(), which sets an initial max_mtu of 1500, while the
>underlying hardware can handle something much larger. Just set it to
>ETH_MAX_MTU to support all possible values, and the limitations of the
>underlying devices will prevent setting anything too large.
>
>Fixes: 91572088e3fd ("net: use core MTU range checking in core net infra")
>CC: Cong Wang <xiyou.wangcong@gmail.com>
>CC: Jiri Pirko <jiri@resnulli.us>
>CC: netdev@vger.kernel.org
>Signed-off-by: Jarod Wilson <jarod@redhat.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
