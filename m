From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: Ethernet-over-UDP virtual network interface
Date: Sun, 4 Mar 2012 12:01:01 -0500
Message-ID: <20120304170101.GH21526@kvack.org>
References: <CAKLmikOBPB7rTZu2EfK26=3AhOQUR8xg8n4ySUKRMFmBkC1J3g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Nejc Skoberne <nejc@skoberne.net>,
	Jernej Kos <kostko@unimatrix-one.org>, gw.2012@tnode.com
To: Mitar <mmitar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:35107 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754538Ab2CDRBD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Mar 2012 12:01:03 -0500
Content-Disposition: inline
In-Reply-To: <CAKLmikOBPB7rTZu2EfK26=3AhOQUR8xg8n4ySUKRMFmBkC1J3g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 04, 2012 at 12:30:01PM +0100, Mitar wrote:
...
> I have found this code:
> 
> https://lwn.net/Articles/199120/
> 
> and was planning to use it as a basis, but use UDP for communication.
> What is a proper way to do UDP communication from a kernel module?
> 
> Best regards and thank you all for the great work you are doing on Linux

Why not use L2TP?  It can operate over UDP (v2 or v3) or directly over IP 
if needed (v3).  L2TPv3 also supports ethernet pseudo-wires.

		-ben
-- 
"Thought is the essence of where you are now."
