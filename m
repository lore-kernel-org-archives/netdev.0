From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH v4] net-netlink: Add a new attribute to expose TOS
 values via netlink
Date: Wed, 12 Oct 2011 12:08:44 -0700
Message-ID: <20111012120844.64568ff2@nehalam.linuxnetplumber.net>
References: <20111012085235.3b78729b@nehalam.linuxnetplumber.net>
	<1318446035-10267-1-git-send-email-muralira@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Muraliraja Muniraju <muralira@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1318446035-10267-1-git-send-email-muralira@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 12 Oct 2011 12:00:35 -0700
Muraliraja Muniraju <muralira@google.com> wrote:

> From: Murali Raja <muralira@google.com>
> 
> This patch exposes the tos value for the TCP sockets when the TOS flag
> is requested in the ext_flags for the inet_diag request. This would mainly be
> used to expose TOS values for both for TCP and UDP sockets. Currently it is
> supported for TCP. When netlink support for UDP would be added the support
> to expose the TOS values would alse be done. For IPV4 tos value is exposed
> and for IPV6 tclass value is exposed.
> 
> Signed-off-by: Murali Raja <muralira@google.com>
> ---
> Changelog since v3:
> - Removed the tos structure from the inet_diag.h
> 
> Changelog since v2:
> - Added support for IPv6 and used better API.
> 
> Changelog since v3:
> - Removed reserved fields.


After this is accepted; it is trivial to add support to ss command.

Acked-by: Stephen Hemminger <shemminger@vyatta.com>
