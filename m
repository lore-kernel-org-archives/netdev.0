From: James Huang <jamesclhuang@gmail.com>
Subject: Re: LRO restructuring?
Date: Thu, 19 Feb 2009 22:20:53 +0000 (UTC)
Message-ID: <loom.20090219T221928-196@post.gmane.org>
References: <loom.20090218T192451-89@post.gmane.org> <20090219135358.GA11319@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:44751 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753337AbZBSWVH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Feb 2009 17:21:07 -0500
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1LaHGQ-0006sc-0h
	for netdev@vger.kernel.org; Thu, 19 Feb 2009 22:21:02 +0000
Received: from 66.151.55.131 ([66.151.55.131])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 19 Feb 2009 22:21:02 +0000
Received: from jamesclhuang by 66.151.55.131 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 19 Feb 2009 22:21:02 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi all,
 
    One question about inet_lro.c (linux 2.6.28.6)
In lro_proc_segment(), it does not check the number of available frags entries 
in lro_desc->parent against the number of new fragments to be added before 
calling lro_add_frags().  Is that a bug?  I see that lro_proc_segment() does 
some type of checking at the end, but could that be too late (i.e. overflow 
the frags[])??
 
    Also I think some obvious optimization in lro_get_desc() can be done by 
combining the two for loops into one.
 
-- James Huang




