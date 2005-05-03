From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2/3] [RTNETLINK] Fix & cleanup rtm_min/rtm_max
Date: Tue, 3 May 2005 14:28:20 -0700
Message-ID: <20050503142820.7a436e58.davem@davemloft.net>
References: <20050430195202.GD577@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050430195202.GD577@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 30 Apr 2005 21:52:02 +0200
Thomas Graf <tgraf@suug.ch> wrote:

> Converts rtm_min and rtm_max arrays to use c99 designated
> initializers for easier insertion of new message families.
> RTM_GETMULTICAST and RTM_GETANYCAST did not have the minimal
> message size specified which means that the netlink message
> was parsed for routing attributes starting from the header.
> Adds the proper minimal message sizes for these messages
> (netlink header + common rtnetlink header) to fix this issue.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied, thanks Thomas.
