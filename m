From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next v14 1/5] openvswitch: Refactor ovs_nla_fill_match().
Date: Wed, 21 Jan 2015 17:16:11 -0800
Message-ID: <CALnjE+ocnU76Ech=kyU7zR+BM74-3oyjxpMoHp92uCe-6opogg@mail.gmail.com>
References: <1421887372-56414-1-git-send-email-joestringer@nicira.com>
	<1421887372-56414-2-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1421887372-56414-2-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 21, 2015 at 4:42 PM, Joe Stringer <joestringer@nicira.com> wrote:
> Refactor the ovs_nla_fill_match() function into separate netlink
> serialization functions ovs_nla_put_{unmasked_key,mask}(). Modify
> ovs_nla_put_flow() to handle attribute nesting and expose the 'is_mask'
> parameter - all callers need to nest the flow, and callers have better
> knowledge about whether it is serializing a mask or not.
>
> Signed-off-by: Joe Stringer <joestringer@nicira.com>

Acked-by: Pravin B Shelar <pshelar@nicira.com>
