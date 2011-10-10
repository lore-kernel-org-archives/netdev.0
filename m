From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] net-netlink: Add a new attribute to expose TOS values
 via netlink
Date: Mon, 10 Oct 2011 13:07:13 -0700
Message-ID: <20111010130713.6df8bfe4@nehalam.linuxnetplumber.net>
References: <1318272866-18082-1-git-send-email-muralira@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller\"" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Muraliraja Muniraju <muralira@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1318272866-18082-1-git-send-email-muralira@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 10 Oct 2011 11:54:26 -0700
Muraliraja Muniraju <muralira@google.com> wrote:

>  
> +/* INET_DIAG_TOS */
> +
> +struct inet_diag_tos {
> +	__u8	idiag_tos;
> +	__u8	idiag_reserved[3];
> +};

No reserved bytes in netlink messages please.
