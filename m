From: James Morris <jmorris@redhat.com>
Subject: Re: [PATCH] linux 2.9.10-rc1: Fix oops in unix_dgram_sendmsg when
 using SELinux and SOCK_SEQPACKET
Date: Thu, 18 Nov 2004 12:11:18 -0500 (EST)
Message-ID: <Xine.LNX.4.44.0411181209380.5179-100000@thoron.boston.redhat.com>
References: <20041118090706.O2357@build.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ross Kendall Axe <ross.axe@blueyonder.co.uk>, <netdev@oss.sgi.com>,
        Stephen Smalley <sds@epoch.ncsc.mil>,
        lkml <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Chris Wright <chrisw@osdl.org>
In-Reply-To: <20041118090706.O2357@build.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 18 Nov 2004, Chris Wright wrote:

> Right, but the snippet I posted guards against that I think.  It forces
> unix_peer_get() in dgram_sendmsg.

Correct.  We could also add more code to dgram_sendmsg() to simply ignore
any address passed in for SOCK_SEQPACKETs, but again, I think that is a
programming error and I think we should signal that, especially as this is
a new feature.



- James
-- 
James Morris
<jmorris@redhat.com>
