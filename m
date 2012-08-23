From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: RE: [net-next 10/13] igb: Tidy up wrapping for CONFIG_IGB_PTP.
Date: Thu, 23 Aug 2012 18:03:57 +0000
Message-ID: <02874ECE860811409154E81DA85FBB5807857EFE@ORSMSX105.amr.corp.intel.com>
References: <1345715813-20757-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1345715813-20757-11-git-send-email-jeffrey.t.kirsher@intel.com>
 <20120823110357.GB2238@netboy.at.omicron.at>
 <06DFBC1E25D8024DB214DC7F41A3CD34488DD039@ORSMSX101.amr.corp.intel.com>
 <20120823172950.GA2192@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Richard Cochran <richardcochran@gmail.com>,
	"Vick, Matthew" <matthew.vick@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:18087 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754582Ab2HWSEq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 14:04:46 -0400
In-Reply-To: <20120823172950.GA2192@netboy.at.omicron.at>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Richard Cochran
> Sent: Thursday, August 23, 2012 10:30 AM
> To: Vick, Matthew
> Cc: Kirsher, Jeffrey T; davem@davemloft.net; netdev@vger.kernel.org;
> gospo@redhat.com; sassmann@redhat.com
> Subject: Re: [net-next 10/13] igb: Tidy up wrapping for CONFIG_IGB_PTP.
> 
> On Thu, Aug 23, 2012 at 04:09:30PM +0000, Vick, Matthew wrote:
> > > -----Original Message-----
> > > From: Richard Cochran [mailto:richardcochran@gmail.com]
> > > Sent: Thursday, August 23, 2012 4:04 AM
> > > To: Kirsher, Jeffrey T
> > > Cc: davem@davemloft.net; Vick, Matthew; netdev@vger.kernel.org;
> > > gospo@redhat.com; sassmann@redhat.com
> > > Subject: Re: [net-next 10/13] igb: Tidy up wrapping for
> CONFIG_IGB_PTP.
> > >
> > > On Thu, Aug 23, 2012 at 02:56:50AM -0700, Jeff Kirsher wrote:
> > > > From: Matthew Vick <matthew.vick@intel.com>
> > > >
> > > > For users without CONFIG_IGB_PTP=y, we should not be compiling any
> > > PTP
> > > > code into the driver. Tidy up the wrapping in igb to support this.
> > >
> > > Actually, you are doing more than that. You are adding a bunch of
> > > comments onto the already existing #endifs.
> >
> > Fair enough. Would you like me to update the patch description?
> 
> Better would be to drop of the pendantic #endif /*CONFIG_FOO*/ stuff.
> It is just churn.
> 

Personally disagree here. I do agree that the churn is annoying with how it breaks git blame, however, in general I prefer tags at the end of #ifdefs even for short ones because it increases my ability to quickly spot matches. The end comment aligns with the starting comment, and even for small blocks makes it easier to process. It is less necessary the smaller the block, but I always prefer to have it than not.

That said, it is nice when git blame points to the right place, and the comments aren't super necessary for such short blocks.

- Jake

> Thanks,
> Richard
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in the
> body of a message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html
