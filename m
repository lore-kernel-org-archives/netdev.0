From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH] veth: don't assign a qdisc to veth
Date: Fri, 3 Oct 2014 22:38:16 +0200
Message-ID: <20141003223816.6c56e6d8@redhat.com>
References: <20141003104858.6745.62964.stgit@dragon>
	<CAHA+R7PMkNefxottnNOq+xhRVW_n+SXQxZYFXoNY1b_xEjWm5g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>, mpatel@redhat.com,
	brouer@redhat.com
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7760 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750750AbaJCUiW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Oct 2014 16:38:22 -0400
In-Reply-To: <CAHA+R7PMkNefxottnNOq+xhRVW_n+SXQxZYFXoNY1b_xEjWm5g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 3 Oct 2014 09:53:16 -0700
Cong Wang <cwang@twopensource.com> wrote:

> On Fri, Oct 3, 2014 at 3:48 AM, Jesper Dangaard Brouer
> <brouer@redhat.com> wrote:
> > The veth driver is a virtual device, and should not have assigned
> > the default qdisc.  Verified (ndo_start_xmit) veth_xmit can only
> > return NETDEV_TX_OK, thus this should be safe to bypass qdisc.
> >
> > Not assigning a qdisc is subtly done by setting tx_queue_len to zero.
> >
> 
> Huh?? Maybe your $subject is too misleading, but we do use HTB
> on veth, this will break our code since we will have to set tx_queue_len
> after your patch, no?

No, you HTB setup should still work.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
