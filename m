From: Dmitry Yusupov <dmitry_yus@yahoo.com>
Subject: Re: [PATCH] NETLINK_UESTABLISHED notifier event
Date: Tue, 05 Apr 2005 16:53:56 -0700
Message-ID: <1112745236.16753.23.camel@beastie>
References: <1112730889.16753.17.camel@beastie> <4253059C.1080000@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jean-Mickael Guerin <jean-mickael.guerin@6wind.com>
In-Reply-To: <4253059C.1080000@6wind.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2005-04-05 at 23:39 +0200, Jean-Mickael Guerin wrote:
> Dmitry Yusupov wrote:
> > This patch provides:
> > 
> > * new event for unicast connections NETLINK_UESTABLISHED.
> 
> Which kind of application takes benefit of this event ?

we have NETLINK_URELEASE already where netlink user usually free
associated resources. It is nice to have NETLINK_UESTABLISHED to
implement reverse needs. For example, netlink user wants to allocate
associated resources or to monitor new connections from user-space
before it actually gets first interrupt from it.

> btw your diff is reversed ;-)

oh, well, I was running out of time. still applicable... :)

> Jean-Mickael
> 
