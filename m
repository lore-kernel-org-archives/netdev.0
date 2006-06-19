From: Andi Kleen <ak@suse.de>
Subject: Re: Network performance degradation from 2.6.11.12 to 2.6.16.20
Date: Mon, 19 Jun 2006 22:39:37 +0200
Message-ID: <200606192239.37533.ak@suse.de>
References: <4492D5D3.4000303@atmos.washington.edu> <200606191724.31305.ak@suse.de> <4496E041.5070501@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk@diku.dk>,
	Harry Edmon <harry@atmos.washington.edu>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.suse.de ([195.135.220.2]:15256 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S932221AbWFSUul (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2006 16:50:41 -0400
To: "Chris Friesen" <cfriesen@nortel.com>
In-Reply-To: <4496E041.5070501@nortel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 19 June 2006 19:34, Chris Friesen wrote:
> Andi Kleen wrote:
> > Incoming packets are only time stamped
> > when someone asks for the timestamps.
>
> Doesn't that add scheduling latency to the timestamps?  Or is is a flag
> that gets set to trigger timestamping at packet arrival?

It's a flag (or more precise a global counter) 

-Andi
