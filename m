From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [net-next 10/13] igb: Tidy up wrapping for CONFIG_IGB_PTP.
Date: Thu, 23 Aug 2012 20:03:47 +0200
Message-ID: <20120823180345.GC2192@netboy.at.omicron.at>
References: <1345715813-20757-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1345715813-20757-11-git-send-email-jeffrey.t.kirsher@intel.com>
 <20120823110357.GB2238@netboy.at.omicron.at>
 <06DFBC1E25D8024DB214DC7F41A3CD34488DD039@ORSMSX101.amr.corp.intel.com>
 <20120823172950.GA2192@netboy.at.omicron.at>
 <06DFBC1E25D8024DB214DC7F41A3CD34488DD257@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: "Vick, Matthew" <matthew.vick@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:57441 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753643Ab2HWSD7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 14:03:59 -0400
Received: by wibhr14 with SMTP id hr14so1293733wib.1
        for <netdev@vger.kernel.org>; Thu, 23 Aug 2012 11:03:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <06DFBC1E25D8024DB214DC7F41A3CD34488DD257@ORSMSX101.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 23, 2012 at 05:40:01PM +0000, Vick, Matthew wrote:
> > Better would be to drop of the pendantic #endif /*CONFIG_FOO*/ stuff.
> > It is just churn.
> > 
> > Thanks,
> > Richard
> 
> I'm willing to drop it, but I would like to drop it universally in the driver if that's the case. Is that acceptable? There's no overly long or complex wrapping section in the driver that I think merits being sloppy with the end comments.

Well, I don't know about the other cases.

drivers/net/ethernet/intel/igb$ grep \#endif *.c | grep -v CONFIG | wc -l
28

drivers/net/ethernet/intel/igb$ grep \#endif *.c | grep CONFIG | wc -l
8

(none of these are for _IGB_PTP)

Having #endif comments is useful when it makes the code more clear. It
is a matter of taste, but I do think having such comments for just two
lines in between is ugly and silly.

Thanks,
Richard
