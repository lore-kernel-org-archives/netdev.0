From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] pktgen: sprintf arg type warning
Date: Sat, 9 Oct 2004 19:36:44 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041009173644.GC30713@wotan.suse.de>
References: <20041008203027.643a2a97.rddunlap@osdl.org> <20041008221934.42a6bc7a.davem@davemloft.net> <41682021.3080400@errno.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        "Randy.Dunlap" <rddunlap@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Sam Leffler <sam@errno.com>
Content-Disposition: inline
In-Reply-To: <41682021.3080400@errno.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Other systems have addressed this problem by extending printf with 
> portable %formats.

Problem is that gcc -Wformat doesn't know the new format codes,
and in Linux we still have to support old gcc versions.

Standard trick is to cast to long.

-Andi
