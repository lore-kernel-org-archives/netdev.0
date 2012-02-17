From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: Re: [PATCH v2 07/10] cisco/enic: use eth_hw_addr_random() instead of random_ether_addr()
Date: Fri, 17 Feb 2012 22:35:42 +0100
Message-ID: <201202172235.43337.danny.kukawka@bisect.de>
References: <1329493411-25750-1-git-send-email-danny.kukawka@bisect.de> <1329493411-25750-8-git-send-email-danny.kukawka@bisect.de> <20120217.160147.1731660099441103969.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: benve@cisco.com, roprabhu@cisco.com, dwang2@cisco.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120217.160147.1731660099441103969.davem@davemloft.net>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Freitag, 17. Februar 2012, David Miller wrote:
> From: Danny Kukawka <danny.kukawka@bisect.de>
> Date: Fri, 17 Feb 2012 16:43:28 +0100
>
> > Use dev_hw_addr_random() instead of calling random_ether_addr()
> > to set addr_assign_type correctly to NET_ADDR_RANDOM.
> >
> > Couldn't replace random_ether_addr() in enic_probe() since
> > enic_set_mac_addr() is used which would reset addr_assign_type.
> > Instead set addr_assign_type directly to NET_ADDR_RANDOM in
> > case of random mac after call enic_set_mac_addr().
> >
> > Reset the state to NET_ADDR_PERM as soon as the MAC get
> > changed via .ndo_set_mac_address.
> >
> > v2: use bitops, adapt to eth_hw_addr_random(), add a comment
> >
> > Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
>
> This patch doesn't apply at all to the current net-next tree,
> please always validate that your patches actually apply to the
> tree before submission.

Okay ... forgot that ... I'll check and send a new version.

Danny
