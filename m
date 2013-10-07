From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH net-next] xen-netback: fix xenvif_count_skb_slots()
Date: Mon, 7 Oct 2013 21:03:00 +0100
Message-ID: <1381176180.27765.39.camel@dagon.hellion.org.uk>
References: <1380903983-27429-1-git-send-email-paul.durrant@citrix.com>
	 <20131007.153622.1392772445100851507.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <paul.durrant@citrix.com>, <xen-devel@lists.xen.org>,
	<netdev@vger.kernel.org>, <xixiong@amazon.com>, <msw@amazon.com>,
	<annie.li@oracle.com>, <wei.liu2@citrix.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:23718 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751995Ab3JGUDE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Oct 2013 16:03:04 -0400
In-Reply-To: <20131007.153622.1392772445100851507.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-10-07 at 15:36 -0400, David Miller wrote:
> From: Paul Durrant <paul.durrant@citrix.com>
> Date: Fri, 4 Oct 2013 17:26:23 +0100
> 
> > Commit 4f0581d25827d5e864bcf07b05d73d0d12a20a5c introduced an error into
> > xenvif_count_skb_slots() for skbs with a linear area spanning a page
> > boundary. The alignment of skb->data needs to be taken into account, not
> > just the head length. This patch fixes the issue by dry-running the code
> > from xenvif_gop_skb() (and adjusting the comment above the function to note
> > that).
> > 
> > Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> 
> There seems to be a lot of back and forth about what is the most
> desirable way forward wrt. this commit and another similar one.
> 
> Please advise.

Lets revert 4f0581d25827d5e864bcf07b05d73d0d12a20a5c and see about
making this stuff less fragile in the future.

Thanks,
Ian.
