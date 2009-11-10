From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH] net: add dataref destructor to sk_buff
Date: Tue, 10 Nov 2009 16:45:44 +0200
Message-ID: <20091110144543.GC19645@redhat.com>
References: <20091002141407.30224.54207.stgit@dev.haskins.net> <20091110115335.GC6989@redhat.com> <4AF919020200005A000586A9@sinclair.provo.novell.com> <20091110131722.GA19645@redhat.com> <4AF9747E.8020408@novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alacrityvm-devel@lists.sourceforge.net, herbert.xu@redhat.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Gregory Haskins <ghaskins@novell.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756628AbZKJOs0@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4AF9747E.8020408@novell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 10, 2009 at 09:11:10AM -0500, Gregory Haskins wrote:
> > You are comparing with skb destructors, not skb data destructors :) skb
> > data destructor is Rusty's patch which he wanted to use for vringfd.  I
> > mean e.g. this:
> > http://lists.openwall.net/netdev/2008/04/18/7
> 
> Ah, I wasn't aware.  I believe Anthony Ligouri had pointed me at this
> same patch earlier this year.  However, more recently when I saw
> skb->destructor() in mainline (seemingly from Rusty), I thought it had
> been accepted and didn't investigate further.

skb->destructor seems to be there as far back as 2.2.0
http://lxr.linux.no/#linux-old+v2.2.0/include/linux/skbuff.h

-- 
MST
