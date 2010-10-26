From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [v3 RFC PATCH 0/4] Implement multiqueue virtio-net
Date: Tue, 26 Oct 2010 10:57:09 +0200
Message-ID: <20101026085709.GC23530@redhat.com>
References: <20101020085452.15579.76002.sendpatchset@krkumar2.in.ibm.com>
 <OF8735A2A4.74B4EE91-ON652577C5.0040D90B-652577C7.0056B99D@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: anthony@codemonkey.ws, arnd@arndb.de, avi@redhat.com,
	davem@davemloft.net, eric.dumazet@gmail.com, kvm@vger.kernel.org,
	netdev@vger.kernel.org, rusty@rustcorp.com.au
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40425 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751414Ab0JZJEJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Oct 2010 05:04:09 -0400
Content-Disposition: inline
In-Reply-To: <OF8735A2A4.74B4EE91-ON652577C5.0040D90B-652577C7.0056B99D@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 25, 2010 at 09:20:38PM +0530, Krishna Kumar2 wrote:
> > Krishna Kumar2/India/IBM@IBMIN wrote on 10/20/2010 02:24:52 PM:
> 
> Any feedback, comments, objections, issues or bugs about the
> patches? Please let me know if something needs to be done.
> 
> Some more test results:
> _____________________________________________________
>          Host->Guest BW (numtxqs=2)
> #       BW%     CPU%    RCPU%   SD%     RSD%
> _____________________________________________________

I think we discussed the need for external to guest testing
over 10G. For large messages we should not see any change
but you should be able to get better numbers for small messages
assuming a MQ NIC card.

-- 
MST
