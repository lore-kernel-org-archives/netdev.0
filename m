From: Miroslav Lichvar <mlichvar@redhat.com>
Subject: Re: Extending socket timestamping API for NTP
Date: Thu, 9 Feb 2017 12:15:29 +0100
Message-ID: <20170209111529.GB1449@localhost>
References: <20170207140144.GA11233@localhost>
 <2DAAE40C-75B6-48F6-B57F-1C72086929B9@me.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Richard Cochran <richardcochran@gmail.com>,
        Jiri Benc <jbenc@redhat.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Willem de Bruijn <willemb@google.com>
To: Denny Page <dennypage@me.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37756 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751922AbdBILPg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Feb 2017 06:15:36 -0500
Content-Disposition: inline
In-Reply-To: <2DAAE40C-75B6-48F6-B57F-1C72086929B9@me.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 08, 2017 at 04:45:05PM -0800, Denny Page wrote:
> > On Feb 07, 2017, at 06:01, Miroslav Lichvar <mlichvar@redhat.com> wrote:
> > 
> > 5) new SO_TIMESTAMPING options to get transposed RX timestamps

> > 6) new SO_TIMESTAMPING option to get PHC index with HW timestamps
> > 
> >   With bridges, bonding and other things it's difficult to determine
> >   which PHC timestamped the packet. It would be very useful if the
> >   PHC index was provided with each HW timestamp.
> > 
> >   I'm not sure what would be the best place to put it. I guess the
> >   second timespec in scm_timestamping could be reused for this, but
> >   that sounds like a gross hack. Do we need to define a new struct?

> Miroslav, if #5 were implemented, would #6 still needed?

Yes. With #5 we wouldn't have to know the link speed of the interface
and guess the length of received packets (or use raw sockets), but we
would still not know which clock has actually timestamped the packet.

-- 
Miroslav Lichvar
