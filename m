From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Subject: Re: [PATCH 0/7] [DCCP]: Further fixes and enhancements
Date: Thu, 21 Sep 2006 23:46:30 -0300
Message-ID: <39e6f6c70609211946g34ea56bbp9eeea01920842901@mail.gmail.com>
References: <200609221425.16349.ian.mcdonald@jandi.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	"dccp (vger)" <dccp@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"Stephen Hemminger" <shemminger@osdl.org>,
	"Andrea Bittau" <a.bittau@cs.ucl.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.228]:60559 "EHLO
	wx-out-0506.google.com") by vger.kernel.org with ESMTP
	id S932226AbWIVCqb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Sep 2006 22:46:31 -0400
Received: by wx-out-0506.google.com with SMTP id s14so874899wxc
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2006 19:46:31 -0700 (PDT)
To: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
In-Reply-To: <200609221425.16349.ian.mcdonald@jandi.co.nz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/21/06, Ian McDonald <ian.mcdonald@jandi.co.nz> wrote:
> Here is my latest set of patches for DCCP.
>
> If possible I would like these to go into 2.6.19. I have tested against
> 2.6.18rc5 and latest net-2.6.19 git tree of Dave M as well.
>
> Dave - Patches 1 and 2 are trivial and just introducing constants and using
> them. Patch 4 is shifting some code into a header. If patch 3 could be
> merged also that would be great - it is just about the same as Stephen
> Hemminger's TCP Probe code but instead for DCCP. Patch 3 depends on patch 1.
>
> I think it would be good for Arnaldo or another person to sign off on 5, 6
> and 7 after a bit more of a look. These fix up packet size setting for
> CCID3 and also change them to work on half connections as you may have
> different packet sizes for each. I've tested myself thoroughly but others
> might have an opinion on the style of these. These three patches need to be
> applied in order.

Everything seems fine, I'll merge them early tomorrow, do some testing
and push to DaveM,

Thanks,

- Arnaldo
