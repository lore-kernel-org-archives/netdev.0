From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] netlink: add NETLINK_CAP_ACK socket option
Date: Fri, 28 Aug 2015 22:25:57 -0700 (PDT)
Message-ID: <20150828.222557.1986611543185633142.davem@davemloft.net>
References: <1440738468-2374-1-git-send-email-christophe-h.ricard@st.com>
	<1440738468-2374-2-git-send-email-christophe-h.ricard@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, jbenc@redhat.com, sfeldma@gmail.com,
	sameo@linux.intel.com, netdev@vger.kernel.org,
	christophe-h.ricard@st.com
To: christophe.ricard@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58262 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752533AbbH2FZ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2015 01:25:58 -0400
In-Reply-To: <1440738468-2374-2-git-send-email-christophe-h.ricard@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christophe Ricard <christophe.ricard@gmail.com>
Date: Fri, 28 Aug 2015 07:07:48 +0200

> Since commit c05cdb1b864f ("netlink: allow large data transfers from
> user-space"), the kernel may fail to allocate the necessary room for the
> acknowledgment message back to userspace. This patch introduces a new
> socket option that trims off the payload of the original netlink message.
> 
> The netlink message header is still included, so the user can guess from
> the sequence number what is the message that has triggered the
> acknowledgment.
> 
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> Signed-off-by: Christophe Ricard <christophe-h.ricard@st.com>

Applied.
