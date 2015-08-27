From: David Miller <davem@davemloft.net>
Subject: Re: [RFC v3] netlink: add NETLINK_CAP_ACK socket option
Date: Thu, 27 Aug 2015 16:33:38 -0700 (PDT)
Message-ID: <20150827.163338.2207468828490017383.davem@davemloft.net>
References: <1440703891-9332-1-git-send-email-christophe-h.ricard@st.com>
	<1440703891-9332-2-git-send-email-christophe-h.ricard@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, jbenc@redhat.com, sfeldma@gmail.com,
	sameo@linux.intel.com, netdev@vger.kernel.org,
	christophe-h.ricard@st.com, stable@vger.kernel.org
To: christophe.ricard@gmail.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1440703891-9332-2-git-send-email-christophe-h.ricard@st.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christophe Ricard <christophe.ricard@gmail.com>
Date: Thu, 27 Aug 2015 21:31:31 +0200

> Since commit c05cdb1b864f ("netlink: allow large data transfers from
> user-space"), the kernel may fail to allocate the necessary room for the
> acknowledgment message back to userspace. This patch introduces a new
> socket option that trims off the payload of the original netlink message.
> 
> The netlink message header is still included, so the user can guess from
> the sequence number what is the message that has triggered the
> acknowledgment.
> 
> Cc: stable@vger.kernel.org

Please do not CC: stable for networking changes, that is not how we handle
-stable submissions.

Instead, please just explicitly ask me to queue it up for -stable when
you make a bonafide non-RFC submission of a change.

Thanks.
