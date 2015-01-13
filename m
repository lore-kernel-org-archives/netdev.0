From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] af_packet: fix typo of "unlikely" conditional in
 packet_snd
Date: Tue, 13 Jan 2015 16:40:27 -0500
Message-ID: <20150113214025.GH14521@tuxdriver.com>
References: <1421176811-22594-1-git-send-email-linville@tuxdriver.com>
 <20150113.142604.824938958848327187.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dborkman@redhat.com,
	hannes@stressinduktion.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:50632 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753707AbbAMVpO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 16:45:14 -0500
Content-Disposition: inline
In-Reply-To: <20150113.142604.824938958848327187.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 13, 2015 at 02:26:04PM -0500, David Miller wrote:
> From: "John W. Linville" <linville@tuxdriver.com>
> Date: Tue, 13 Jan 2015 14:20:11 -0500
> 
> > Change "unlikely(offset) < 0" to "unlikely(offset < 0)"...
> > 
> > Coverity: CID 1259984
> > 
> > Signed-off-by: John W. Linville <linville@tuxdriver.com>
> 
> Should be fixed in the 'net' tree by:
> 
> commit 46d2cfb192b30d729aef064808ed5ece47cee369
> Author: Christoph Jaeger <cj@linux.com>
> Date:   Sun Jan 11 13:01:16 2015 -0500
> 
>     packet: bail out of packet_snd() if L2 header creation fails

Cool, sorry for the noise!

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
