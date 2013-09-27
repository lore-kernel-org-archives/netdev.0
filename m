From: Ben Pfaff <blp@nicira.com>
Subject: Re: [PATCH v2.40 6/7] datapath: Break out deacceleration portion of
 vlan_push
Date: Fri, 27 Sep 2013 12:48:57 -0700
Message-ID: <20130927194857.GE17506@nicira.com>
References: <1380241116-7661-1-git-send-email-horms@verge.net.au>
 <1380241116-7661-7-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dev@openvswitch.org, netdev@vger.kernel.org,
	Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Joe Stringer <joe@wand.net.nz>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog101.obsmtp.com ([74.125.149.67]:37000 "HELO
	na3sys009aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753639Ab3I0TtF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Sep 2013 15:49:05 -0400
Received: by mail-pa0-f53.google.com with SMTP id kq14so3226622pab.12
        for <netdev@vger.kernel.org>; Fri, 27 Sep 2013 12:49:02 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1380241116-7661-7-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 27, 2013 at 09:18:35AM +0900, Simon Horman wrote:
> Break out deacceleration portion of vlan_push into vlan_put
> so that it may be re-used by mpls_push.
> 
> For both vlan_push and mpls_push if there is an accelerated VLAN tag
> present then it should be deaccelerated, adding it to the data of
> the skb, before the new tag is added.
> 
> Signed-off-by: Simon Horman <horms@verge.net.au>

I think Jesse already reviewed and approved patches 6 and 7, but I don't
see any Acked-by attached to them.
