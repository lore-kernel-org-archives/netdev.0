From: "John Heffner" <johnwheffner@gmail.com>
Subject: Re: Socket buffer sizes with autotuning
Date: Mon, 28 Apr 2008 16:28:16 -0700
Message-ID: <1e41a3230804281628r363f9d3cn7b0eee0bd6423e65@mail.gmail.com>
References: <d1c2719f0804231629p4536e98do668b812e34d2b92c@mail.gmail.com>
	 <1e41a3230804240932u510609beh8fb577baaadeb9bd@mail.gmail.com>
	 <d1c2719f0804241749p2c0dd7daofd343bc37a916247@mail.gmail.com>
	 <20080424.234628.170849475.davem@davemloft.net>
	 <d1c2719f0804281130n7b0aaab8t54b2a585cff53a99@mail.gmail.com>
	 <1e41a3230804281221s11442a82j55c363116988a5cb@mail.gmail.com>
	 <d1c2719f0804281338j3984cf2bga31def0c2c1192a1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	rick.jones2@hp.com
To: "Jerry Chu" <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.180]:27879 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753453AbYD1X2R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2008 19:28:17 -0400
Received: by wa-out-1112.google.com with SMTP id m16so8349397waf.23
        for <netdev@vger.kernel.org>; Mon, 28 Apr 2008 16:28:16 -0700 (PDT)
In-Reply-To: <d1c2719f0804281338j3984cf2bga31def0c2c1192a1@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 28, 2008 at 1:38 PM, Jerry Chu <hkchu@google.com> wrote:
> > Try this series of patches, against net-next.
>
> Ah, you already know about this problem. Yes it does the trick.

I had not actually known about this.  (Just cooked up the patches
after I saw your mail.)  This looks to me like a clear bug.  After
looking carefully at the code there, it seems there was another small
problem, too, though not likely to have much effect.

Dave, can you apply the patches I just sent?

Thanks,
  -John
