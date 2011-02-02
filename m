From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: Network performance with small packets
Date: Wed, 02 Feb 2011 09:12:57 -0800
Message-ID: <1296666777.25430.37.camel@localhost.localdomain>
References: <20110201215603.GA31348@redhat.com>
	 <1296601197.26937.833.camel@localhost.localdomain>
	 <20110202044002.GB3818@redhat.com>
	 <1296626748.26937.852.camel@localhost.localdomain>
	 <1296627549.26937.856.camel@localhost.localdomain>
	 <20110202062950.GD3818@redhat.com>
	 <1296630891.26937.870.camel@localhost.localdomain>
	 <1296632029.26937.871.camel@localhost.localdomain>
	 <20110202104946.GC8505@redhat.com>
	 <1296661371.25430.13.camel@localhost.localdomain>
	 <20110202154841.GB12738@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	Steve Dobbelstein <steved@us.ibm.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	mashirle@linux.vnet.ibm.com, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:59622 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754627Ab1BBRNC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Feb 2011 12:13:02 -0500
In-Reply-To: <20110202154841.GB12738@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-02-02 at 17:48 +0200, Michael S. Tsirkin wrote:
> And this is with sndbuf=0 in host, yes?
> And do you see a lot of tx interrupts?
> How packets per interrupt?

Nope, sndbuf doens't matter since I never hit reaching sock wmem
condition in vhost. I am still playing around, let me know what data you
would like to collect.

Thanks
Shirley

