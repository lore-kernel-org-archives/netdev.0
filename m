From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] linux 2.9.10-rc1: Fix oops in unix_dgram_sendmsg when
	using SELinux and SOCK_SEQPACKET
Date: Fri, 19 Nov 2004 11:39:22 +0000
Message-ID: <1100864358.8127.5.camel@localhost.localdomain>
References: <Xine.LNX.4.44.0411182207080.7831-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ross Kendall Axe <ross.axe@blueyonder.co.uk>, netdev@oss.sgi.com,
        Stephen Smalley <sds@epoch.ncsc.mil>,
        lkml <linux-kernel@vger.kernel.org>, Chris Wright <chrisw@osdl.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
In-Reply-To: <Xine.LNX.4.44.0411182207080.7831-100000@thoron.boston.redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Gwe, 2004-11-19 at 03:12, James Morris wrote:
> On Thu, 18 Nov 2004, Alan Cox wrote:
> 
> > As to the other stuff I think the only change needed is to check the
> > queued asynchronous error and report that before going on to the
> > connected test
> 
> How about this?

Looks right to me, the ECONNRESET is no longer being lost.
