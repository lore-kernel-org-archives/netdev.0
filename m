From: Joe Perches <joe@perches.com>
Subject: Re: [RFC] Any value in having a netdev FAQ?
Date: Tue, 16 Jul 2013 13:42:35 -0700
Message-ID: <1374007355.1949.21.camel@joe-AO722>
References: <20130716025954.GC26761@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Darren Hart <dvhart@linux.intel.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:38463 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932993Ab3GPUmh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jul 2013 16:42:37 -0400
In-Reply-To: <20130716025954.GC26761@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-07-15 at 22:59 -0400, Paul Gortmaker wrote:
> Q: Any other tips to help ensure my net/net-next patch gets OK'd?
> 
> A: Attention to detail.  You can start with checkpatch.pl, but do not
>    be mindlessly robotic in doing so.

Suggest checkpatch.pl --strict because there are some
style elements (like multi-line statement alignment)
where checkpatch bleats with --strict that are commonly
used in net and drivers/net. 

email the proposed patch to yourself and make sure it
applies cleanly before sending it to the netdev mailing
list.
