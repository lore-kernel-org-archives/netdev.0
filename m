From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Thu, 02 Apr 2009 21:43:36 -0700
Message-ID: <49D593F8.3030006@goop.org>
References: <20090402085253.GA29932@gondor.apana.org.au> <49D487A6.407@redhat.com> <49D49C1F.6030306@novell.com> <200904022243.21088.rusty@rustcorp.com.au> <20090402151020.GB1986@dhcp-1-124.tlv.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	Gregory Haskins <ghaskins@novell.com>,
	Avi Kivity <avi@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	anthony@codemonkey.ws, andi@firstfloor.org,
	linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, netdev@vger.kernel.org, kvm@vger.kernel.org
To: "Michael S. Tsirkin" <m.s.tsirkin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.goop.org ([64.81.55.164]:38818 "EHLO mail.goop.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751500AbZDCEnk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Apr 2009 00:43:40 -0400
In-Reply-To: <20090402151020.GB1986@dhcp-1-124.tlv.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael S. Tsirkin wrote:
> Rusty, I think this is what you did in your patch from 2008 to add destructor
> for skb data ( http://kerneltrap.org/mailarchive/linux-netdev/2008/4/18/1464944 ):
> and it seems that it would make zero-copy possible - or was there some problem with
> that approach? Do you happen to remember?
>   

I'm planning on resurrecting it to replace the page destructor used by 
Xen netback.

    J

