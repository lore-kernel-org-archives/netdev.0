From: "Vick, Matthew" <matthew.vick@intel.com>
Subject: RE: [net-next 10/13] igb: Tidy up wrapping for CONFIG_IGB_PTP.
Date: Thu, 23 Aug 2012 18:40:25 +0000
Message-ID: <06DFBC1E25D8024DB214DC7F41A3CD34488DD35B@ORSMSX101.amr.corp.intel.com>
References: <1345715813-20757-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1345715813-20757-11-git-send-email-jeffrey.t.kirsher@intel.com>
 <20120823110357.GB2238@netboy.at.omicron.at>
 <06DFBC1E25D8024DB214DC7F41A3CD34488DD039@ORSMSX101.amr.corp.intel.com>
 <20120823172950.GA2192@netboy.at.omicron.at>
 <02874ECE860811409154E81DA85FBB5807857EFE@ORSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: "Keller, Jacob E" <jacob.e.keller@intel.com>,
	Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:53613 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932555Ab2HWSkc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 14:40:32 -0400
In-Reply-To: <02874ECE860811409154E81DA85FBB5807857EFE@ORSMSX105.amr.corp.intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Keller, Jacob E
> Sent: Thursday, August 23, 2012 11:04 AM
> To: Richard Cochran; Vick, Matthew
> Cc: Kirsher, Jeffrey T; davem@davemloft.net; netdev@vger.kernel.org;
> gospo@redhat.com; sassmann@redhat.com
> Subject: RE: [net-next 10/13] igb: Tidy up wrapping for CONFIG_IGB_PTP.
> 
> [...]
> 
> Personally disagree here. I do agree that the churn is annoying with
> how it breaks git blame, however, in general I prefer tags at the end
> of #ifdefs even for short ones because it increases my ability to
> quickly spot matches. The end comment aligns with the starting comment,
> and even for small blocks makes it easier to process. It is less
> necessary the smaller the block, but I always prefer to have it than
> not.
> 
> That said, it is nice when git blame points to the right place, and the
> comments aren't super necessary for such short blocks.
> 
> - Jake

I tend to agree with Jake here--I like having the information. I'm fine removing them, but I'd like to do it for all CONFIG_IGB_PTP wrapping if we're going to do it. What do you think, Richard?

Cheers,
Matthew
