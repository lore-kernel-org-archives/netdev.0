From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] ipv4 tcp autobind problem
Date: Mon, 29 Sep 2003 22:22:09 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030929222209.4d02c542.davem@redhat.com>
References: <3F782E1F.4030500@balabit.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Kovacs Krisztian <hidden@balabit.hu>
In-Reply-To: <3F782E1F.4030500@balabit.hu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Once connect() has been called on a socket, you may not ever again
perform any action that would try to connect that socket.

Said another way, a socket that has failed to connect() is a socket
that you may not use in any usable way ever again except to close
that file descriptor.
