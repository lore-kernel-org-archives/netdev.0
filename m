From: David Miller <davem@davemloft.net>
Subject: Re: [take9 1/2] kevent: Core files.
Date: Wed, 16 Aug 2006 12:45:54 -0700 (PDT)
Message-ID: <20060816.124554.18301763.davem@davemloft.net>
References: <20060816134550.GA12345@infradead.org>
	<20060816135642.GD4314@2ka.mipt.ru>
	<44E35F29.8010500@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, hch@infradead.org,
	linux-kernel@vger.kernel.org, drepper@redhat.com, akpm@osdl.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:60869
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932112AbWHPTpy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Aug 2006 15:45:54 -0400
To: zach.brown@oracle.com
In-Reply-To: <44E35F29.8010500@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zach Brown <zach.brown@oracle.com>
Date: Wed, 16 Aug 2006 11:08:41 -0700

> >>> +	for (i=0; i<ARRAY_SIZE(u->kevent_list); ++i)
> >> 	for (i = 0; i < ARRAY_SIZE(u->kevent_list); i++)
> > 
> > Ugh, no. It reduces readability due to exessive number of spaces.
> 
> Ihavetoverystronglydisagree.

Metoo. :-)

Spaces help humans parse out the syntactic structure of
multi-token expressions.
