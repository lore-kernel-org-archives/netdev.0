From: Florian Zumbiehl <florz@florz.de>
Subject: Re: [PATCH 4/4] PPPoE: race between interface going down and release()
Date: Tue, 13 Mar 2007 06:08:36 +0100
Message-ID: <20070313050835.GJ17712@florz.florz.dyndns.org>
References: <20070311044143.GD17712@florz.florz.dyndns.org> <1173667016.24373.36.camel@kdsk1.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Michal Ostrowski <mostrows@earthlink.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from odnb-d9bbfa3f.pool.mediaWays.net ([217.187.250.63]:3946 "EHLO
	rain.florz.dyndns.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753128AbXCMF4c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Mar 2007 01:56:32 -0400
Content-Disposition: inline
In-Reply-To: <1173667016.24373.36.camel@kdsk1.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> Attached below is my take on how to address this problem.  
> This addresses any concerns you may have had about checking po->pppoe_dev==NULL,
> because accesses to this field are now synchronized with pppoe_hash_lock.

That indeed looks like a much cleaner solution, so I'd certainly prefer
it over mine. Testing so far didn't turn up any problems, either.

> Once we can settle on a fix for this, I'll deal with the SID==0 issue 
> (trying to do that now would just cause patch conflicts).

Well, yeah, this stuff probably is more important than support
for SID 0 :-)

Florian
