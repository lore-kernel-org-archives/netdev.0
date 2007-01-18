From: "Jon Smirl" <jonsmirl@gmail.com>
Subject: Re: [PATCH] Marvell Libertas 8388 802.11b/g USB driver (v2)
Date: Thu, 18 Jan 2007 17:54:09 -0500
Message-ID: <9e4733910701181454k3d01f018hddbe0568d14f6d8f@mail.gmail.com>
References: <20070116185524.GA5681@dmt>
	 <1169020333.9175.15.camel@johannes.berg> <20070117184204.GA3899@dmt>
	 <20070117230654.GA9387@infradead.org>
	 <1169134905.2788.16.camel@localhost.localdomain>
	 <20070118224008.GA6675@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Dan Williams" <dcbw@redhat.com>,
	"Marcelo Tosatti" <marcelo@kvack.org>,
	"Johannes Berg" <johannes@sipsolutions.net>,
	netdev <netdev@vger.kernel.org>,
	"Jeff Garzik" <jgarzik@pobox.com>,
	"John W. Linville" <linville@redhat.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	"Arnd Bergmann" <arnd@arndb.de>,
	"Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.239]:25684 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932734AbXARWyK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jan 2007 17:54:10 -0500
Received: by nz-out-0506.google.com with SMTP id s1so258956nze
        for <netdev@vger.kernel.org>; Thu, 18 Jan 2007 14:54:10 -0800 (PST)
To: "Christoph Hellwig" <hch@infradead.org>
In-Reply-To: <20070118224008.GA6675@infradead.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/18/07, Christoph Hellwig <hch@infradead.org> wrote:
> On Thu, Jan 18, 2007 at 10:41:45AM -0500, Dan Williams wrote:
> > In the future we'll likely need some layering to support the 8385
> > SDIO/CF variant, but most likely not in way the USB support is currently
> > excessively layered and abstracted.
>
> Yeah.  Let's summarize my unfortunately a bit too nasty comments and
> your more helpfull replies :-)
>
> This driver still needs a lot more work, both to cleanup a lot of crap
> and integrate it better with the wireless stack.  And OLPC needs this
> is not going to be an excuse of it's own.

The main feature of this chip is the on-chip support for 802.11s in
firmware. What is the plan for integrating 802.11s into the existing
wireless stacks? Does it make sense to do a softmac type 802.11s
implementation first to figure out the right places to put the hooks
for the 8388 hardware implementation?

-- 
Jon Smirl
jonsmirl@gmail.com
