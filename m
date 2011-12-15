From: Benjamin Poirier <benjamin.poirier@gmail.com>
Subject: Re: twice past the taps, thence out to net?
Date: Wed, 14 Dec 2011 19:58:02 -0500
Message-ID: <20111215005802.GA11552@d2.synalogic.ca>
References: <4EE8F884.1010304@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tcpdump-workers@lists.tcpdump.org, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:63089 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755008Ab1LOA6H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2011 19:58:07 -0500
Received: by vbbfc26 with SMTP id fc26so1123817vbb.19
        for <netdev@vger.kernel.org>; Wed, 14 Dec 2011 16:58:06 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <4EE8F884.1010304@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/12/14 11:27, Rick Jones wrote:
> 
> Where in the Linux stack does the tap used by libpcap 1.1.1 reside?
> 

On transmission it's before tso/gso, via dev_queue_xmit_nit(). Taps are
registered in the ptype_all list.

-Benjamin
