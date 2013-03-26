From: James Harper <james.harper@bendigoit.com.au>
Subject: RE: [Xen-devel] [PATCH 5/6] xen-netback: coalesce slots before
 copying
Date: Tue, 26 Mar 2013 10:52:56 +0000
Message-ID: <6035A0D088A63A46850C3988ED045A4B3880B43D@BITCOM1.int.sbss.com.au>
References: <1364209702-12437-1-git-send-email-wei.liu2@citrix.com>
	<1364209702-12437-6-git-send-email-wei.liu2@citrix.com>
	<5150699C.6080209@citrix.com>
	<CAOsiSVUNO0FQkfJWjv9bcoMgKNnHu4XYciz61hG3YNFzZNxK3w@mail.gmail.com>
	<51507C9B.3080109@citrix.com>
	<CAOsiSVV8gtKqFxyAr3XN9YF78WjtFqzvx5mnA1dKTrS_4qzXBw@mail.gmail.com>
	<51509789.8090608@citrix.com> <20130325190911.GC7004@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wei Liu <liuw@liuw.name>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"annie.li@oracle.com" <annie.li@oracle.com>
To: Wei Liu <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bendigoit.com.au ([203.16.207.99]:55811 "EHLO
	smtp2.bendigoit.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756426Ab3CZKxS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 06:53:18 -0400
In-Reply-To: <20130325190911.GC7004@zion.uk.xensource.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > It's not clear why 19 or 20 were suggested as possible values.  I
> > checked back to 2.6.18 and MAX_SKB_FRAGS there is (65536/PAGE_SIZE +
> 2)
> 
> Because the check is >= MAX_SKB_FRAGS originally and James Harper told
> me that "Windows stops counting on 20".
> 

I've obviously not been clear enough here... GPLPV stopped counting at 20 (only needed to know if <20 or not). Windows itself can submit a packet to NDIS with hundreds of buffers. It doesn't really matter if it's 21 or 1021, I just didn't want to be misquoted.

James
