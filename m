From: Mark Salter <msalter@redhat.com>
Subject: Re: [PATCH v8 4/4] drivers: net: Add APM X-Gene SoC ethernet driver
 support.
Date: Wed, 25 Jun 2014 12:40:45 -0400
Message-ID: <1403714445.755.112.camel@deneb.redhat.com>
References: <1403306296-26198-1-git-send-email-isubramanian@apm.com>
	 <1403306296-26198-5-git-send-email-isubramanian@apm.com>
	 <CALdTtnvHt5mYMC3619E4F3KK0jPOw7mCpKE6bTn0Um6fdZ4rbw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Iyappan Subramanian <isubramanian@apm.com>, davem@davemloft.net,
	netdev@vger.kernel.org,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	linux-arm-kernel@lists.infradead.org, jcm@redhat.com,
	patches@apm.com, Ravi Patel <rapatel@apm.com>,
	Keyur Chudgar <kchudgar@apm.com>
To: Dann Frazier <dann.frazier@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47563 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756944AbaFYQl1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jun 2014 12:41:27 -0400
In-Reply-To: <CALdTtnvHt5mYMC3619E4F3KK0jPOw7mCpKE6bTn0Um6fdZ4rbw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-06-24 at 22:29 -0600, Dann Frazier wrote:
> On Fri, Jun 20, 2014 at 5:18 PM, Iyappan Subramanian
> > +       ring->desc_addr = dma_zalloc_coherent(dev, size, &ring->dma,
> > +                                             GFP_KERNEL);
> 
> Iyappan,
> When testing this driver on a 3.16-rc2 base, I'm finding that
> desc_addr gets assigned to NULL here, which results in an oops later
> on (see below).
> 
> I wasn't seeing this before (3.15 base), so I'm guessing something
> changed upstream, or in my config, to change this behavior. But it
> does illuminate a place where we could maybe use some better error
> handling (also see below).

https://lkml.org/lkml/2014/6/23/10
