From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: Add missing include for in6_addr
Date: Thu, 18 Apr 2013 13:51:32 -0400 (EDT)
Message-ID: <20130418.135132.1342139552386927867.davem@davemloft.net>
References: <1366276658-11938-1-git-send-email-sven@open-mesh.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: sven@open-mesh.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1366276658-11938-1-git-send-email-sven@open-mesh.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Sven Eckelmann <sven@open-mesh.com>
Date: Thu, 18 Apr 2013 11:17:38 +0200

> ee07c6e7a6f8a25c18f0a6b18152fbd7499245f6 ("bridge: export multicast database
> via netlink") added "struct br_mdb_entry" which includes an element using the
> type "struct in6_addr". The file linux/if_bridge.h is part of the uapi and not
> defining this type in this file or its includes causes build failures in
> userspace applications.
> 
> Signed-off-by: Sven Eckelmann <sven@open-mesh.com>

This will conflict with the in6_addr defined by the libc headers, we're
screwed either way here, so we might as well require userspace to include
the libc header that defines this type.
