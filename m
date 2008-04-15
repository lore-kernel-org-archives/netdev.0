From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: RE: A Linux TCP SACK Question
Date: Tue, 15 Apr 2008 20:08:45 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0804152005110.27927@wrl-59.cs.helsinki.fi>
References: <fc471cb97cfd.47f5520e@fnal.gov>  <000701c898bf$99fc3f80$c95ee183@D2GT6T71>
  <Pine.LNX.4.64.0804080007020.20936@wrl-59.cs.helsinki.fi>
 <fbbce0572843.47fb038c@fnal.gov>  <Pine.LNX.4.64.0804081623500.21784@wrl-59.cs.helsinki.fi>
  <fba201de4228.47fb3b26@fnal.gov>  <Pine.LNX.4.64.0804081742270.21784@wrl-59.cs.helsinki.fi>
  <000301c89e81$80124570$6b5ee183@D2GT6T71>  <1e41a3230804141748v2bf1f32bsc80307c9390c222@mail.gmail.com>
  <fcb2d79550b4.480493e2@fnal.gov> <1e41a3230804151001gc9fa670p511b16bb01e0bc93@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Wenji Wu <wenji@fnal.gov>, Netdev <netdev@vger.kernel.org>
To: John Heffner <johnwheffner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:54619 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757159AbYDORIz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 13:08:55 -0400
In-Reply-To: <1e41a3230804151001gc9fa670p511b16bb01e0bc93@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 15 Apr 2008, John Heffner wrote:

> On Tue, Apr 15, 2008 at 9:39 AM, Wenji Wu <wenji@fnal.gov> wrote:
> >  SlowStart            0
> >  CongAvoid            0
> >  CongestionSignals    3
> >  OtherReductions      13166
> >  X_OtherReductionsCV  0
> >  X_OtherReductionsCM  13166
> >  CongestionOverCount  37
> >  CurCwnd              10136
> >
> > MaxCwnd              173760
> >  CurSsthresh          94894680
> >  LimCwnd              4294965848
> >  MaxSsthresh          94894680
> >  MinSsthresh          46336
> 
> 
> We can see that in both cases you are getting throttled by
> tcp_moderate_cwnd (X_OtherReductionsCM).  I'm not sure offhand why
> it's reaching this code - I would have thought that the high
> tp->reordering would prevent this.  Ilpo, do you have any insights?

What makes you think so? It's called from tcp_try_to_open as anyone can 
read from the source, basically when our state is CA_Disorder (some very 
small portion might happen in ca_recovery besides that).


-- 
 i.
