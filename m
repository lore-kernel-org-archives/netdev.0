From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] select congestion control with one sysctl
Date: Wed, 23 Feb 2005 13:57:32 -0800
Message-ID: <20050223135732.39e62c6c.davem@davemloft.net>
References: <421CF5E5.1060606@ev-en.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com, linux-net@vger.kernel.org,
        yee-ting.li@nuim.ie, doug.leith@nuim.ie
To: Baruch Even <baruch@ev-en.org>
In-Reply-To: <421CF5E5.1060606@ev-en.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


For the millionth time, you can't just delete the existing sysctls.
That is a user visisble interface.

Instead, you have to make them at least appear to select a
single congestion control algorithm as I stated in the
following posting:

http://marc.theaimsgroup.com/?l=linux-kernel&m=110909973530321&w=2
