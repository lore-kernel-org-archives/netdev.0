From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] [IPV4]: Exclude "All deletion of equal addresses only
 differing by prefix length."
Date: Thu, 31 Mar 2005 10:36:08 -0800
Message-ID: <20050331103608.447a21a5.davem@davemloft.net>
References: <20050331124747.GT3086@postel.suug.ch>
	<Pine.LNX.4.61.0503312047110.26294@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Savola <pekkas@netcore.fi>
In-Reply-To: <Pine.LNX.4.61.0503312047110.26294@netcore.fi>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 31 Mar 2005 20:48:05 +0300 (EEST)
Pekka Savola <pekkas@netcore.fi> wrote:

> On Thu, 31 Mar 2005, Thomas Graf wrote:
> > The address deletion fix is no longer needed since a better fix
> > has made it into iproute2. Better in terms of same hack but in
> > userspace so we don't confuse other netlink users.
> 
> So, does that mean that all the users are expected to always run the 
> latest iproute2, so there's no need for backward-compat in the kernel?

No, that's not what is happening here.

Thomas originally added a hack to the API in the kernel to handle this,
but now he's backing that out because the problem can be solved
purely in userspace.

This API change is only visible during 2.6.12 development and never
appeared in a stable release, so we can pull it out now safely.
