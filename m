From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [RFC PATCH] rtnetlink: Fix problem with buffer allocation
Date: Fri, 10 Feb 2012 19:30:20 +0000
Message-ID: <C5551D9AAB213A418B7FD5E4A6F30A0702F88D50@ORSMSX106.amr.corp.intel.com>
References: <20120210150518.4002.85507.stgit@gitlad.jf.intel.com>
	<20120210.135151.754379087490167636.davem@davemloft.net>
	<C5551D9AAB213A418B7FD5E4A6F30A0702F88CF8@ORSMSX106.amr.corp.intel.com>
 <20120210.142452.2227318248629247303.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:30256 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752637Ab2BJTa1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2012 14:30:27 -0500
In-Reply-To: <20120210.142452.2227318248629247303.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Friday, February 10, 2012 11:25 AM
> To: Rose, Gregory V
> Cc: netdev@vger.kernel.org
> Subject: Re: [RFC PATCH] rtnetlink: Fix problem with buffer allocation
> 
> From: "Rose, Gregory V" <gregory.v.rose@intel.com>
> Date: Fri, 10 Feb 2012 19:07:15 +0000
> 
> > OK, sounds good.  How about I also add a field to indicate the
> > application buffer size?
> 
> How can this help, we already have it.  It's the length field to
> the recvmsg() call.

Ah, I hadn't seen that.

Ok.

- Greg

> 
> Also, either the user provided a large enough buffer or he didn't.  If
> he didn't we return an error to the recvmsg() call, and the user can
> increase the buffer size and try again.
