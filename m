From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC] Extend netlink error codes
Date: Fri, 10 Sep 2004 16:07:36 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040910160736.309bc29c.davem@davemloft.net>
References: <20040910225158.GO20088@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, hadi@cyberus.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20040910225158.GO20088@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 11 Sep 2004 00:51:58 +0200
Thomas Graf <tgraf@suug.ch> wrote:

> Once in netlink_ack, split the combined error message again,
> fill the existing errno into nlerrmsg.error and provide the
> netlink specific error code in a newly introduced TLV. This
> way, no binaries or old applications would break, but
> applications can support it and provide more meanigful error
> message with almost no effort.

It sounds like it could work.

Jamal, any objections to his idea?
