From: Omar Laazimani <omar.oberthur@gmail.com>
Subject: Re: [PATCH] : CDC EEM driver patch to be applied to 2.6.30 kernel
Date: Mon, 4 May 2009 22:58:46 +0200
Message-ID: <3a98b4410905041358r6b5e2133r1b07fefa0239da08@mail.gmail.com>
References: <3a98b4410904270912g1838b534j2b53561b8caa1543@mail.gmail.com>
	 <200905031713.58762.david-b@pacbell.net>
	 <3a98b4410905040851i20d4192ax8f9ff3953e635979@mail.gmail.com>
	 <200905041027.45948.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: David Brownell <david-b@pacbell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.25]:10160 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754021AbZEDU6q convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2009 16:58:46 -0400
Received: by ey-out-2122.google.com with SMTP id 9so1074286eyd.37
        for <netdev@vger.kernel.org>; Mon, 04 May 2009 13:58:46 -0700 (PDT)
In-Reply-To: <200905041027.45948.david-b@pacbell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2009/5/4 David Brownell <david-b@pacbell.net>:
> On Monday 04 May 2009, Omar Laazimani wrote:
>> Thanks for your quick feedbacks.
>> I have tested your patch with our device and it's working well.
>
> Hmm, one more issue. =A0The eem_unbind() isn't needed at all,
> is it?? =A0It seems leftover from the ACM or ECM code, which
> needed a separate control interface. =A0Nothing even sets up
> the data used by that routine (other than zero-init).
>

You're right. The eem_unbind() isn't needed and I forgot to remove it.

> - Dave
>
