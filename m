From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] linux 2.9.10-rc1: Fix oops in unix_dgram_sendmsg when
	using SELinux and SOCK_SEQPACKET
Date: Thu, 18 Nov 2004 16:49:00 +0000
Message-ID: <1100796518.6019.11.camel@localhost.localdomain>
References: <Xine.LNX.4.44.0411180305060.3192-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ross Kendall Axe <ross.axe@blueyonder.co.uk>, netdev@oss.sgi.com,
        Stephen Smalley <sds@epoch.ncsc.mil>,
        lkml <linux-kernel@vger.kernel.org>, Chris Wright <chrisw@osdl.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
In-Reply-To: <Xine.LNX.4.44.0411180305060.3192-100000@thoron.boston.redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Iau, 2004-11-18 at 08:27, James Morris wrote:
> 2) Ensure that unix_dgram_sendmsg() fails for SOCK_SEQPACKET sockets which
> are not connected, otherwise someone could bypass LSM by sending on an
> unconnected socket.

What about half closed and other connected states ? This patch seems
inadequate for things like X.25
