From: "Thibaut VARENE" <T-Bone@parisc-linux.org>
Subject: Re: kernel BUG in eth_alloc_tx_desc_index at drivers/net/mv643xx_eth.c:1069!
Date: Wed, 10 Jan 2007 18:12:29 +0100
Message-ID: <7d01f9f00701100912kc6fb635wd863d9563b0eb328@mail.gmail.com>
References: <7d01f9f00701051103q3ee6ed35q9fd0f778a18061b8@mail.gmail.com>
	 <20070109092602.GC1703@ff.dom.local>
	 <7d01f9f00701090227v60b37e5dy6afbf70ccde58bf2@mail.gmail.com>
	 <20070109130220.GA4060@ff.dom.local>
	 <7d01f9f00701090944o62f39fb4yfaa5449c2d2d010d@mail.gmail.com>
	 <20070109200541.GA27089@xyzzy.farnsworth.org>
	 <7d01f9f00701091305n3a82713fla442a70a6098dbf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Jarek Poplawski" <jarkao2@o2.pl>, netdev@vger.kernel.org,
	mlachwani@mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.237]:28777 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964970AbXAJRMb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jan 2007 12:12:31 -0500
Received: by wr-out-0506.google.com with SMTP id i30so98474wra
        for <netdev@vger.kernel.org>; Wed, 10 Jan 2007 09:12:30 -0800 (PST)
To: "Dale Farnsworth" <dale@farnsworth.org>
In-Reply-To: <7d01f9f00701091305n3a82713fla442a70a6098dbf@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/9/07, Thibaut VARENE <T-Bone@parisc-linux.org> wrote:
> On 1/9/07, Dale Farnsworth <dale@farnsworth.org> wrote:
> >
> > Thank you Thibaut.  Please try the following patch:
> >
> > From: Dale Farnsworth <dale@farnsworth.org>
> >
> > Reserve one unused descriptor in the TX ring
> > to facilitate testing for when the ring is full.
>
> Dale,
>
> tried it and unfortunately:

Also, I don't know if you read that bit, but everytime I reboot the
box immediately after a crash, the NIC gets a bogus (always the same
it seems) MAC address, and I have to reboot one more time to get back
to the "normal" MAC address.

Dunno if that hints anything though.

HTH

-- 
Thibaut VARENE
http://www.parisc-linux.org/~varenet/
