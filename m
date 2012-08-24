From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [net-next 10/13] igb: Tidy up wrapping for CONFIG_IGB_PTP.
Date: Fri, 24 Aug 2012 12:10:53 +0200
Message-ID: <20120824101053.GA6038@netboy.at.omicron.at>
References: <1345715813-20757-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1345715813-20757-11-git-send-email-jeffrey.t.kirsher@intel.com>
 <20120823110357.GB2238@netboy.at.omicron.at>
 <06DFBC1E25D8024DB214DC7F41A3CD34488DD039@ORSMSX101.amr.corp.intel.com>
 <20120823172950.GA2192@netboy.at.omicron.at>
 <02874ECE860811409154E81DA85FBB5807857EFE@ORSMSX105.amr.corp.intel.com>
 <06DFBC1E25D8024DB214DC7F41A3CD34488DD35B@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Keller, Jacob E" <jacob.e.keller@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: "Vick, Matthew" <matthew.vick@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:54177 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751356Ab2HXKLF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 06:11:05 -0400
Received: by weyx8 with SMTP id x8so924462wey.19
        for <netdev@vger.kernel.org>; Fri, 24 Aug 2012 03:11:04 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <06DFBC1E25D8024DB214DC7F41A3CD34488DD35B@ORSMSX101.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 23, 2012 at 06:40:25PM +0000, Vick, Matthew wrote:
> 
> I tend to agree with Jake here--I like having the information. I'm fine removing them, but I'd like to do it for all CONFIG_IGB_PTP wrapping if we're going to do it. What do you think, Richard?

Come to think of it, I never liked the CONFIG_IGB_PTP very much in the
first place. These were added after the fact by Jeff Kirsher. He had
said off list that there was some issue with CONFIG_PTP_1588_CLOCK and
igb as a module, or something like that. At that time I said, just go
ahead and fix it up.

I think it would be better if the "time stamp all Rx packets" of the
82580 were always available, and that the PHC feature always be
compiled when CONFIG_PTP_1588_CLOCK is selected.

Maybe you could ask Jeff what the issue was, and then see if there is
a way to remove CONFIG_IGB_PTP altogether.

Thanks,
Richard
