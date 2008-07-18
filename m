From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [PATCH] tcp: do not promote SPLICE_F_NONBLOCK to socket O_NONBLOCK
Date: Fri, 18 Jul 2008 21:43:38 +0300
Message-ID: <200807182143.38624.opurdila@ixiacom.com>
References: <200807171633.49791.opurdila@ixiacom.com> <200807182116.43451.opurdila@ixiacom.com> <20080718183549.GA23263@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	axboe@kernel.dk
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760287AbYGRSp6@vger.kernel.org>
In-Reply-To: <20080718183549.GA23263@2ka.mipt.ru>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 18 July 2008, Evgeniy Polyakov wrote:

> >
> > and so on until pipe->nrbufs is 16. At than point, we will block in
> > pipe_wait, inside splice_to_pipe.
>
> Seems that SPLICE_F_NONBLOCK check should be propagated from
> tcp_splice_read() into skb_splice_bits(), and this flag is actually
> there already in tss.flags.

I'm not sure I understand you... 

The flag gets propagated to splice_to_pipe (so there is no need to propagate 
the check in skb_splice_bits) but we don't have SPLICE_F_NONBLOCK set, we are 
on the blocking usecase.

Thanks,
tavi
