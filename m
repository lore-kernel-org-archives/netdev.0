From: "Jerry Chu" <hkchu@google.com>
Subject: Re: Socket buffer sizes with autotuning
Date: Mon, 12 May 2008 21:00:08 -0700
Message-ID: <d1c2719f0805122100u7e550820xff6fcdbc1e538948@mail.gmail.com>
References: <20080512.152900.220913361.davem@davemloft.net>
	 <20080512.153114.163063885.davem@davemloft.net>
	 <d1c2719f0805122056ib4c1af7pfa7f95f6e38c7e32@mail.gmail.com>
	 <20080512.205837.215391489.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:55894 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750748AbYEMEAW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2008 00:00:22 -0400
Received: from zps35.corp.google.com (zps35.corp.google.com [172.25.146.35])
	by smtp-out.google.com with ESMTP id m4D40Cvi007527
	for <netdev@vger.kernel.org>; Tue, 13 May 2008 05:00:12 +0100
Received: from hs-out-0708.google.com (hscm63.prod.google.com [10.44.114.63])
	by zps35.corp.google.com with ESMTP id m4D409Ae014086
	for <netdev@vger.kernel.org>; Mon, 12 May 2008 21:00:10 -0700
Received: by hs-out-0708.google.com with SMTP id m63so2296129hsc.11
        for <netdev@vger.kernel.org>; Mon, 12 May 2008 21:00:09 -0700 (PDT)
In-Reply-To: <20080512.205837.215391489.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Does xchg() return the old value? (Can't find any comments on it.)

Jerry

On Mon, May 12, 2008 at 8:58 PM, David Miller <davem@davemloft.net> wrote:
> From: "Jerry Chu" <hkchu@google.com>
>  Date: Mon, 12 May 2008 20:56:16 -0700
>
>
>  > If true, can we use some atomic operation to zap in_flight, but also
>  > return to the caller if in_flight has been nullified already so that
>  > the accounting can be handled correctly?
>
>  xchg() should work for that purpose.
>
