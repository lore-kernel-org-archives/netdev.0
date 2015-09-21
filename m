From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [iproute2 net-next] ip route: Add RTM_F_LOOKUP_TABLE flag and
 show table id
Date: Mon, 21 Sep 2015 16:03:00 -0600
Message-ID: <56007E94.8000506@cumulusnetworks.com>
References: <1442859588-14831-1-git-send-email-dsa@cumulusnetworks.com>
 <20150921141929.681ebf69@urahara> <56007695.3070003@cumulusnetworks.com>
 <20150921.145800.1946648892912159723.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:36009 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932558AbbIUWCz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 18:02:55 -0400
Received: by padbj2 with SMTP id bj2so2843747pad.3
        for <netdev@vger.kernel.org>; Mon, 21 Sep 2015 15:02:54 -0700 (PDT)
In-Reply-To: <20150921.145800.1946648892912159723.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/21/15 3:58 PM, David Miller wrote:
> I think if it always gave MAIN in older kernels, iproute should continue
> to do so.
>
> You can't just remove the table ID output just because you disagree with
> the semantics given by old kernels.
>

Current semantics are maintained. Kernel was hardcoded to return main; 
iproute2 was hardcoded to not show main.
