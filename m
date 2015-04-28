From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH net] bnx2x: really disable TPA if 'disable_tpa' option
 is set
Date: Tue, 28 Apr 2015 09:11:41 +0000
Message-ID: <B5657A6538887040AD3A81F1008BEC63D23FAC@AVMB1.qlogic.org>
References: <1430148038-25695-1-git-send-email-mschmidt@redhat.com>,<20150427.134323.156569796484222010.davem@davemloft.net>
 <B5657A6538887040AD3A81F1008BEC63D2041C@AVMB1.qlogic.org>
 <553F4D3F.7000301@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Dmitry Kravkov <Dmitry.Kravkov@qlogic.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: Michal Schmidt <mschmidt@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:44926 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932894AbbD1JLq convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Apr 2015 05:11:46 -0400
In-Reply-To: <553F4D3F.7000301@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > I agree that this fixes an incorrect logic, but its incomplete as the
> > bnx2x 'bp->flags' no longer represent the correct logic. I.e., it
> > might cause additional issues down the road, as the 'fp->mode' and 'fp-
> >disable_tpa'
> > are no longer in sync.
> 
> > We already have a fix for this issue, we just haven't sent it to 'net'
> > yet. Are you willing to give us an additional day to send an
> > alternative fix?  Or do you prefer to take this, and possibly later
> > we'll remove the logic added by this patch in our own?
> 
> Yuval,
> 
> I also have a patch that removes fp->disable_tpa by merging it into
> fp->mode (adding a 3rd mode: TPA_MODE_DISABLED). And another patch that
> removes {TPA,GRO}_ENABLE_FLAG by using dev->features everywhere.
> I'll wait and see what changes you have.
> 
> Regards,
> Michal

Ours is merely a point fix that differentiate GRO_ENABLE_FLAG from
NETIF_F_GRO.
If you have a ready patch that removes the flags altogether I think
we can skip ours and review that one instead.

Thanks,
Yuval
