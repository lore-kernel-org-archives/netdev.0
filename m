From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.4] Use double-linked list for dev->qdisc_list
Date: Wed, 4 Aug 2004 13:44:32 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040804134432.40500c15.davem@redhat.com>
References: <20040804125926.GA15324@krezus.e-wro.net>
	<4110E505.1010205@trash.net>
	<20040804145610.GA21339@krezus.e-wro.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Tomasz Paszkowski <tomasz.paszkowski@e-wro.pl>
In-Reply-To: <20040804145610.GA21339@krezus.e-wro.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 4 Aug 2004 16:56:10 +0200
Tomasz Paszkowski <tomasz.paszkowski@e-wro.pl> wrote:

> On Wed, Aug 04, 2004 at 03:30:45PM +0200, Patrick McHardy wrote:
> > Looks good, except for the last hunk, the BUG_TRAP is valid in 2.4 because
> > it doesn't use RCU. Change it to BUG_TRAP(list_empty(&dev->qdisc_list)).
> 
> Thanks. In attachment there's a corrected version of this patch.

Can someone regenerate this patch with the q_idx fix Patrick
just posted added to it?

Thanks.
