From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] linux 2.9.10-rc1: Fix oops in unix_dgram_sendmsg when
 using SELinux and SOCK_SEQPACKET
Date: Fri, 19 Nov 2004 23:11:00 -0800
Message-ID: <20041119231100.34b32431.davem@davemloft.net>
References: <1100864358.8127.5.camel@localhost.localdomain>
	<Xine.LNX.4.44.0411191122470.10340-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: alan@lxorguk.ukuu.org.uk, ross.axe@blueyonder.co.uk,
	netdev@oss.sgi.com, sds@epoch.ncsc.mil,
	linux-kernel@vger.kernel.org, chrisw@osdl.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262916AbUKTH1M@vger.kernel.org>
To: James Morris <jmorris@redhat.com>
In-Reply-To: <Xine.LNX.4.44.0411191122470.10340-100000@thoron.boston.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 19 Nov 2004 11:24:03 -0500 (EST)
James Morris <jmorris@redhat.com> wrote:

> On Fri, 19 Nov 2004, Alan Cox wrote:
> 
> > Looks right to me, the ECONNRESET is no longer being lost.
> 
> Ok, here is a relative patch for Dave.
> 
> Please apply.
> 
> Signed-off-by: James Morris <jmorris@redhat.com>

Applied, thanks for fixing this up.
