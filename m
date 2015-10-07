From: Sowmini Varadhan <sowmini05@gmail.com>
Subject: Re: [PATCH net-next v4] net: ipv6: Make address flushing on ifdown optional
Date: Wed, 7 Oct 2015 11:43:06 -0400
Message-ID: <CACP96tQtGecigUUHdF32w91qj=abqJLo+evzOL-9JakSJZ064A@mail.gmail.com>
References: <1444231059-14830-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, hannes@redhat.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:33464 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754036AbbJGPnI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 11:43:08 -0400
Received: by wiclk2 with SMTP id lk2so219849606wic.0
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2015 08:43:07 -0700 (PDT)
In-Reply-To: <1444231059-14830-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 7, 2015 at 11:17 AM, David Ahern <dsa@cumulusnetworks.com> wrote:
> Currently, all ipv6 addresses are flushed when the interface is configured
> down, including global, static addresses:
  :
>
> Add a new sysctl to make this behavior optional. The new setting defaults to
> flush all addresses to maintain backwards compatibility. When the setting is
> reset global addresses with no expire times are not flushed:

does src addr selection also need to be modified to know if/when it can/cannot
use this static address as a source addr? Or does the TENTATIVE flag
make it Do The Right Thing per rfc 3484?

--Sowmini
