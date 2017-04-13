From: Miroslav Lichvar <mlichvar@redhat.com>
Subject: Re: [RFC PATCH 0/7] Extend socket timestamping API
Date: Thu, 13 Apr 2017 11:53:54 +0200
Message-ID: <20170413095354.GA7490@localhost>
References: <20170412141737.5881-1-mlichvar@redhat.com>
 <02874ECE860811409154E81DA85FBB5857E00EB6@ORSMSX115.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Willem de Bruijn <willemb@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Denny Page <dennypage@me.com>, Jiri Benc <jbenc@redhat.com>
To: "Keller, Jacob E" <jacob.e.keller@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34600 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751368AbdDMJyG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Apr 2017 05:54:06 -0400
Content-Disposition: inline
In-Reply-To: <02874ECE860811409154E81DA85FBB5857E00EB6@ORSMSX115.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 13, 2017 at 09:08:08AM +0000, Keller, Jacob E wrote:
> > -----Original Message-----
> > This patchset adds new options to the timestamping API that will be
> > useful for NTP implementations and possibly other applications.

> I think this looks pretty good, straight forward and useful. I agree with Richard about the one commit message, but the rest looks good modulo missing updates for all the other drivers.

Thanks for the review.

> I didn't see any code to update the ethtool get_ts_info data for _NTP_ALL either.

My understanding was that ethtool should list only filters that are
actually supported by the HW and are not handled just by switching to
a more general filter. I think that's what drivers I've looked were
doing. The phyter driver would be the only one that could list the
filter as supported. Is that correct?

-- 
Miroslav Lichvar
