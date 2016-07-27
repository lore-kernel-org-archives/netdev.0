From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: problem with MPLS and TSO/GSO
Date: Wed, 27 Jul 2016 10:03:25 +0300
Message-ID: <20160727070325.GB1397@wantstofly.org>
References: <20160725163915.GE10080@wantstofly.org>
 <CAD=hENdOy-d0v9BskuvfqF3qdbrWCy2b-Dc-LSSUcZBmHy-X1A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Ahern <dsa@cumulusnetworks.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Robert Shearman <rshearma@brocade.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	netdev <netdev@vger.kernel.org>
To: zhuyj <zyjzyj2000@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hmm.wantstofly.org ([138.201.34.84]:48592 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751472AbcG0HD1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2016 03:03:27 -0400
Content-Disposition: inline
In-Reply-To: <CAD=hENdOy-d0v9BskuvfqF3qdbrWCy2b-Dc-LSSUcZBmHy-X1A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 27, 2016 at 03:02:24PM +0800, zhuyj wrote:

> On ubuntu16.04 server 64 bit
> The attached script is run, the following will appear.
> 
> Error: either "to" is duplicate, or "encap" is a garbage.

Looks like your installed iproute2 package doesn't grok MPLS.
