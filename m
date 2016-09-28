From: marcelo.leitner@gmail.com
Subject: Re: [PATCHv2 net 0/5] sctp: some fixes of prsctp polices
Date: Wed, 28 Sep 2016 12:44:06 -0300
Message-ID: <20160928154406.GB4008@localhost.localdomain>
References: <cover.1475059350.git.lucien.xin@gmail.com>
 <20160928.081303.661512609700070565.davem@davemloft.net>
 <CADvbK_eKrZaGf0uDsCBdkWCw9e51W-HVL=_WLsR4RaSKjNmqqA@mail.gmail.com>
 <20160928.111716.1982951742537758888.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lucien.xin@gmail.com, netdev@vger.kernel.org,
        linux-sctp@vger.kernel.org, vyasevich@gmail.com,
        daniel@iogearbox.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56556 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932767AbcI1PoW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 28 Sep 2016 11:44:22 -0400
Content-Disposition: inline
In-Reply-To: <20160928.111716.1982951742537758888.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 28, 2016 at 11:17:16AM -0400, David Miller wrote:
> From: Xin Long <lucien.xin@gmail.com>
> Date: Wed, 28 Sep 2016 20:35:40 +0800
> 
> >>
> >>> This patchset is to improve some codes about prsctp polices, and also
> >>> to fix some issues.
> >>>
> >>> v1->v2:
> >>>   - wrap the check of chunk->sent_count in a macro:
> >>>     sctp_chunk_retransmitted in patch 2/5.
> >>
> >> This series is a mix of bug fixes (patch #1) which should be targetting
> >> 'net' and simplifications/cleanups (patch #2-5) which should be targetting
> >> 'net-next'.
> >>
> >> Please do not mix things up like this, and submit patches targetting
> >> the appropriate tree.
> >>
> > understand, I wanted to divide them.
> > but this patchset is special, the following patches
> > depend on patch 1/5.
> 
> That doesn't matter.  This happens all the time.
> 
> The way you handle this is you submit patch #1 targetting 'net' and
> wait for it to get into 'net' and propagate into 'net-next'.  When
> that happens you can submit patches #2-5 as a second patch series
> targetting 'net-next'.

Thanks for your patience for explaining this, David, appreciated.

  Marcelo
