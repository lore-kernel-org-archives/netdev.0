From: "Andy Gospodarek" <andy@greyhouse.net>
Subject: Re: [TG3]: Workaround MSI bug on 5714/5780.
Date: Thu, 6 Sep 2007 10:40:58 -0400
Message-ID: <bdfc5d6e0709060740x302c90f2qfe7d0e4bb9957e0e@mail.gmail.com>
References: <1189022828.4960.2.camel@dell>
	 <20070906.040235.71121480.davem@davemloft.net>
	 <20070906134508.GA10317@gospo.rdu.redhat.com>
	 <20070906.073423.74747465.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.244]:53823 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751445AbXIFOk7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2007 10:40:59 -0400
Received: by an-out-0708.google.com with SMTP id d31so27954and
        for <netdev@vger.kernel.org>; Thu, 06 Sep 2007 07:40:58 -0700 (PDT)
In-Reply-To: <20070906.073423.74747465.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/6/07, David Miller <davem@davemloft.net> wrote:
> From: Andy Gospodarek <andy@greyhouse.net>
> Date: Thu, 6 Sep 2007 09:45:16 -0400
>
> > Is is really necessary to get rid of the HT1000 patch?
>
> Yes, absolutely and without a single doubt.
>
> > commit e3008dedff4bdc96a5f67224cd3d8d12237082a0
> > Author: Andy Gospodarek <andy@greyhouse.net>
> > Date:   Thu May 10 22:58:57 2007 -0700
> >
> >     PCI: disable MSI by default on systems with Serverworks HT1000 chips
> >
> > This patch was designed to address tg3 and bnx2 messages printed on
> > systems with HT1000 chips IIRC.  Are we going back to those messages on
> > bnx2 or is there a workaround in that driver needed too?
>
> Every report of that problem is with tg3 chips afflicted by this
> INTX bug which is now worked around properly.
>
> Even my Niagara T1000 box was hit by this absolutely stupid and
> wrong MSI quirk, which is how I found this problem to begin with.
>
> I'm reverting it.
>

Sounds great.  I never liked it that much to begin with but no one
NACKED it, so it slipped in through Greg KH's tree.
