From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] bridge: netfilter: fix information leak
Date: Mon, 14 Feb 2011 16:50:31 +0100
Message-ID: <4D594F47.8070500@trash.net>
References: <1297680875-11663-1-git-send-email-segoon@openwall.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, security@kernel.org,
	Bart De Schuymer <bart.de.schuymer@pandora.be>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	ebtables-user@lists.sourceforge.net,
	ebtables-devel@lists.sourceforge.net,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org
To: Vasiliy Kulikov <segoon@openwall.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1297680875-11663-1-git-send-email-segoon@openwall.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 14.02.2011 11:54, schrieb Vasiliy Kulikov:
> Struct tmp is copied from userspace.  It is not checked whether the "name"
> field is NULL terminated.  This may lead to buffer overflow and passing
> contents of kernel stack as a module name to try_then_request_module() and,
> consequently, to modprobe commandline.  It would be seen by all userspace
> processes.
> 
> Signed-off-by: Vasiliy Kulikov <segoon@openwall.com>

Applied, thanks Vasiliy.
