From: David Miller <davem@davemloft.net>
Subject: Re: Socket buffer sizes with autotuning
Date: Mon, 12 May 2008 20:58:37 -0700 (PDT)
Message-ID: <20080512.205837.215391489.davem@davemloft.net>
References: <20080512.152900.220913361.davem@davemloft.net>
	<20080512.153114.163063885.davem@davemloft.net>
	<d1c2719f0805122056ib4c1af7pfa7f95f6e38c7e32@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hkchu@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55963
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754850AbYEMD6n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2008 23:58:43 -0400
In-Reply-To: <d1c2719f0805122056ib4c1af7pfa7f95f6e38c7e32@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jerry Chu" <hkchu@google.com>
Date: Mon, 12 May 2008 20:56:16 -0700

> If true, can we use some atomic operation to zap in_flight, but also
> return to the caller if in_flight has been nullified already so that
> the accounting can be handled correctly?

xchg() should work for that purpose.
