From: "Dhananjay Phadke" <dhananjay.phadke@gmail.com>
Subject: Re: [PATCH 0/2] netxen: bug fixes for multiport adapters
Date: Tue, 24 Jul 2007 22:27:24 +0530
Message-ID: <ab901500707240957n24d00cc0s8865956d88ff0166@mail.gmail.com>
References: <20070720190749.535704712@netxen.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Jeff Garzik" <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.240]:10616 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761614AbXGXQ5Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2007 12:57:25 -0400
Received: by an-out-0708.google.com with SMTP id d31so389558and
        for <netdev@vger.kernel.org>; Tue, 24 Jul 2007 09:57:24 -0700 (PDT)
In-Reply-To: <20070720190749.535704712@netxen.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff,

Any chance of these patches getting committed soon?

Thanks,
-Dhananjay Phadke

On 7/21/07, dhananjay@netxen.com <dhananjay@netxen.com> wrote:
> These patches include fix for problem with 2nd port of multiport adapters
> on IBM blades. Also improves interrupt handling for multiport adapters
> avoiding interrupt flood after interrupt is down.
>
> Generated against upstream-fixes.
>
>  drivers/net/netxen/netxen_nic.h          |    3 +-
>  drivers/net/netxen/netxen_nic_main.c     |   85 +++++++++++++++---------------
>  2 files changed, 43 insertions(+), 45 deletions(-)
>
> --
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
