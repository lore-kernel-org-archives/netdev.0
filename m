From: James Huang <jamesclhuang@gmail.com>
Subject: Re: LRO restructuring?
Date: Wed, 18 Feb 2009 19:25:49 +0000 (UTC)
Message-ID: <loom.20090218T192451-89@post.gmane.org>
References: <20080811.175434.215224347.davem@davemloft.net> <20080812010004.GD18547@gondor.apana.org.au> <48A0E7A3.6030200@hp.com> <20080811.183913.09225669.davem@davemloft.net> <20080812015321.GA19011@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:41724 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752097AbZBRTaJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Feb 2009 14:30:09 -0500
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1LZs7O-0000Ux-9o
	for netdev@vger.kernel.org; Wed, 18 Feb 2009 19:30:02 +0000
Received: from 66.151.55.131 ([66.151.55.131])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 18 Feb 2009 19:30:02 +0000
Received: from jamesclhuang by 66.151.55.131 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 18 Feb 2009 19:30:02 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Herbert,

    Any idea when this LRO restructuring work will be done? 
Making LRO available even when ip forwarding is enabled will significantly 
improve performace of network appliances in the data path.  

I have some questions on this: 
(1) Based on the emails in this thread, I suppose you are going to keep the 
original length of each segment you coalesced into the big packet and use that 
info to segment the big packet on the output path.  In case the packet was 
modified by an appliance in the path and the total length is changed (e.g. NAT 
on ftp control packets), should the corresponding segment length info also get 
updated?  This same question also applies to the checksums.

(2) Do you make sure all of the segments to be coalesced have the same DF bit?

(3) I think bridged packets should not be LROed. Whether a packet is bridged 
or not can be based on the L2 MAC destination address.  Is this how it is done?

(4) Does LRO work only for IPv4?  Any plan to extend it to support IPv6?

Thanks,
James Huang




