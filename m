From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [net-next 10/13] igb: Tidy up wrapping for CONFIG_IGB_PTP.
Date: Thu, 23 Aug 2012 19:29:50 +0200
Message-ID: <20120823172950.GA2192@netboy.at.omicron.at>
References: <1345715813-20757-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1345715813-20757-11-git-send-email-jeffrey.t.kirsher@intel.com>
 <20120823110357.GB2238@netboy.at.omicron.at>
 <06DFBC1E25D8024DB214DC7F41A3CD34488DD039@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: "Vick, Matthew" <matthew.vick@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:52797 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964908Ab2HWRaD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 13:30:03 -0400
Received: by wibhr14 with SMTP id hr14so1260056wib.1
        for <netdev@vger.kernel.org>; Thu, 23 Aug 2012 10:30:00 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <06DFBC1E25D8024DB214DC7F41A3CD34488DD039@ORSMSX101.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 23, 2012 at 04:09:30PM +0000, Vick, Matthew wrote:
> > -----Original Message-----
> > From: Richard Cochran [mailto:richardcochran@gmail.com]
> > Sent: Thursday, August 23, 2012 4:04 AM
> > To: Kirsher, Jeffrey T
> > Cc: davem@davemloft.net; Vick, Matthew; netdev@vger.kernel.org;
> > gospo@redhat.com; sassmann@redhat.com
> > Subject: Re: [net-next 10/13] igb: Tidy up wrapping for CONFIG_IGB_PTP.
> > 
> > On Thu, Aug 23, 2012 at 02:56:50AM -0700, Jeff Kirsher wrote:
> > > From: Matthew Vick <matthew.vick@intel.com>
> > >
> > > For users without CONFIG_IGB_PTP=y, we should not be compiling any
> > PTP
> > > code into the driver. Tidy up the wrapping in igb to support this.
> > 
> > Actually, you are doing more than that. You are adding a bunch of
> > comments onto the already existing #endifs.
> 
> Fair enough. Would you like me to update the patch description?

Better would be to drop of the pendantic #endif /*CONFIG_FOO*/ stuff.
It is just churn.

Thanks,
Richard
