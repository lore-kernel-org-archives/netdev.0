From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] rtnetlink & address family problem
Date: 06 Dec 2004 21:27:41 -0500
Message-ID: <1102386461.1093.26.camel@jzny.localdomain>
References: <41B0A5B4.6060108@suse.cz> <20041206140214.GA749@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Michal Ludvig <mludvig@suse.cz>, Andrew Morton <akpm@osdl.org>,
        Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com,
        Jan Kara <jack@suse.cz>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041206140214.GA749@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-12-06 at 09:02, Thomas Graf wrote:

> Your patch would fix this issue but might break various things. The
> actual problem is that iproute2 doesn't check the family in its filter.
> It blindly assumes that the kernel only returns addresses of the kind it
> has requested. I can understand if you think the current behaviour
> is wrong but we shouldn't change it in the middle of a stable tree.

Why would it be wrong? The PF_UNSPEC is there for a purpose.

If user space decides it wants to flush ipv4 addresses blindly that user
spaces fault. The patch you attached seems legit. did you verify it?

BTW, Stephen - are you still updating iproute2? 

cheers,
jamal
