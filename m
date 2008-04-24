From: "John Heffner" <johnwheffner@gmail.com>
Subject: Re: Socket buffer sizes with autotuning
Date: Thu, 24 Apr 2008 09:32:38 -0700
Message-ID: <1e41a3230804240932u510609beh8fb577baaadeb9bd@mail.gmail.com>
References: <d1c2719f0804231629p4536e98do668b812e34d2b92c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Jerry Chu" <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rn-out-0910.google.com ([64.233.170.184]:9904 "EHLO
	rn-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753695AbYDXQco (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 12:32:44 -0400
Received: by rn-out-0910.google.com with SMTP id e11so1453994rng.17
        for <netdev@vger.kernel.org>; Thu, 24 Apr 2008 09:32:40 -0700 (PDT)
In-Reply-To: <d1c2719f0804231629p4536e98do668b812e34d2b92c@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 23, 2008 at 4:29 PM, Jerry Chu <hkchu@google.com> wrote:
>
> I've been seeing the same problem here and am trying to fix it.
>  My fix is to not count those pkts still in the host queue as "prior_in_flight"
>  when feeding the latter to tcp_cong_avoid(). This should cause
>  tcp_is_cwnd_limited() test to fail when the previous in_flight build-up
>  is all due to the large host queue, and stop the cwnd to grow beyond
>  what's really necessary.

Sounds like a useful optimization.  Do you have a patch?

  -John
