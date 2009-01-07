From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: RE: can't apply sch_multiq
Date: Wed, 7 Jan 2009 13:10:03 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0901071304130.11851@ask.diku.dk>
References: <4963392A.2000709@bigtelecom.ru>
 <80769D7B14936844A23C0C43D9FBCF0F24A2DE19@orsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Badalian Vyacheslav <slavon@bigtelecom.ru>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>
To: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:46941 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751466AbZAGMKG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jan 2009 07:10:06 -0500
In-Reply-To: <80769D7B14936844A23C0C43D9FBCF0F24A2DE19@orsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 6 Jan 2009, Duyck, Alexander H wrote:

> Badalian Vyacheslav wrote:
>> Hello all.
>> kernel 2.6.28, iproute2 - 2.6.26 (last release)
>>
> The only part that is probably missing is that I don't believe the 
> sch_multiq patch been accepted into the iproute2.  Once that is in then 
> tc should work with the multiq qdisc without any issues.

You can use the lastest iproute2 git tree at:

  git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git

I just checked that the sch_multiq changes have been added to this tree 
(although it looks like Stephen just added that patch yesterday ;-))

Cheers,
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
