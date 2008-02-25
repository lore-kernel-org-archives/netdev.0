From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: Re: [PATCH] llc: fix skb size for test responses
Date: Mon, 25 Feb 2008 17:30:19 +0900
Message-ID: <b25c3fa70802250030l2a6420caw6c423683ccb7089b@mail.gmail.com>
References: <20080224190758.GW84358@surrealistic.net>
	 <20080224.185104.207884881.davem@davemloft.net>
	 <20080225050421.GY84358@surrealistic.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	acme@ghostprotocols.net
To: "Jim Westfall" <jwestfall@surrealistic.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.237]:15622 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753774AbYBYIaV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2008 03:30:21 -0500
Received: by wx-out-0506.google.com with SMTP id h31so1393861wxd.4
        for <netdev@vger.kernel.org>; Mon, 25 Feb 2008 00:30:20 -0800 (PST)
In-Reply-To: <20080225050421.GY84358@surrealistic.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2008/2/25, Jim Westfall <jwestfall@surrealistic.net>:
> David Miller <davem@davemloft.net> wrote [02.24.08]:
> > From: Jim Westfall <jwestfall@surrealistic.net>
> > Date: Sun, 24 Feb 2008 11:07:58 -0800
> >
> > > Hi
> > >
> > > The llc test command is used for a layer2 ping and contains a variable
> > > length payload that we must include in the response.  Use the size of the
> > > received skb as the size of the skb we must allocate to hold the payload.
> > >
> > > This resolved an skb_over_panic(), when trying to copy the payload into
> > > what was a hard coded skb of size 128.
> > >
> > > Signed-off-by: Jim Westfall <jwestfall@surrealistic.net>
> >
> > Arnaldo, please review Jim's patch, thanks!
>
> Our of curiosity did you all get my 2nd patch?
>
> Subject: [PATCH] llc: dont trust payload size on test cmd
>
> I sent it a few minutes after this one, but seems like it never made it
> to the list.  My local smtp shows it was delivered sucussfully to
> vger.kernel.org.
>

Jim,
Could you please send it again?
I cannot find your second patch on the list.
I have a pending patch for LLC as well, so I want to avoid conflict with yours.

Thanks,
Joonwoo
