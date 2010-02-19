From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH] greth: some driver cleanups
Date: Fri, 19 Feb 2010 13:51:51 +0100
Message-ID: <20100219125148.GA6598@psychotron.redhat.com>
References: <20100219111439.GA4046@coldcone>
 <20100219120425.GD2644@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kristoffer@gaisler.com, netdev@vger.kernel.org
To: kirjanov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55156 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751152Ab0BSMwM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Feb 2010 07:52:12 -0500
Content-Disposition: inline
In-Reply-To: <20100219120425.GD2644@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


<snip>
>>@@ -1031,7 +1029,7 @@ static void greth_set_multicast_list(struct net_device *dev)
>> 			return;
>> 		}
>> 
>>-		if (dev->mc_count == 0) {
>>+		if (!netdev_mc_count(dev)) {
also please use netdev_mc_empty() here.

