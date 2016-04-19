From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [RFC PATCH v2 net-next 2/7] tcp: Merge
 tx_flags/tskey/txstamp_ack in tcp_collapse_retrans
Date: Tue, 19 Apr 2016 11:18:02 -0700
Message-ID: <20160419181644.GA40600@kafai-mba.local>
References: <1461019569-3037369-1-git-send-email-kafai@fb.com>
 <1461019569-3037369-3-git-send-email-kafai@fb.com>
 <CACSApvY5ZdyUO1i2O0KPGJM5meWHFv3hdi9Ew89CH--jFV4yOw@mail.gmail.com>
 <20160419172837.GA37697@kafai-mba.local>
 <CANn89iJ=Kk3oNbkJ4pOg6bnvJFOUjJa6SSem1jb=BOkR0FF=3g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Soheil Hassas Yeganeh <soheil@google.com>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Soheil Hassas Yeganeh <soheil.kdev@gmail.com>,
	Willem de Bruijn <willemb@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Kernel Team <kernel-team@fb.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:51322 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752407AbcDSSSM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 14:18:12 -0400
Content-Disposition: inline
In-Reply-To: <CANn89iJ=Kk3oNbkJ4pOg6bnvJFOUjJa6SSem1jb=BOkR0FF=3g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 19, 2016 at 10:35:52AM -0700, Eric Dumazet wrote:
> On Tue, Apr 19, 2016 at 10:28 AM, Martin KaFai Lau <kafai@fb.com> wrote:
>
> > A bit off topic, I feel like the SKBTX_ACK_TSTAMP and txstamp_ack are sort
> > of redundant but I have not look into the details yet, so not completely
> > sure.  It wwould be a separate cleanup patch if it is the case.
>
> Please read 6b084928baac562ed61866f540a96120e9c9ddb7 changelog ;)
>
> A cache line miss avoidance is critical
I looked at the patch but I probably am missing something :(
Is checking txstamp_ack alone enough and SKBTX_ACK_TSTAMP is not needed
since they are always set together?
