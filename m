From: Vincent Li <vincent.mc.li@gmail.com>
Subject: Re: kernel policy routing table src ip not respected since 2.6.37 and
 commit 9fc3bbb4a752
Date: Tue, 15 Oct 2013 14:38:52 -0700
Message-ID: <CAK3+h2wUY_JuD=jAX9KH8Jvnxey5mJ05G5_STorwuVeBhmJo1g@mail.gmail.com>
References: <CAK3+h2zGFnbC-hpPB8fPX7TC3rKCWbPYVY4WW4HDYbN+LXNXXw@mail.gmail.com>
	<alpine.LFD.2.03.1310151144580.1562@ssi.bg>
	<CAK3+h2w13isZEOurBMv57L0H_pkqMdYmPaNE3Kn5vPxfqErOMw@mail.gmail.com>
	<alpine.LFD.2.03.1310152242170.1919@ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Joel Sing <jsing@google.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:54995 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933696Ab3JOVix (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Oct 2013 17:38:53 -0400
Received: by mail-ob0-f181.google.com with SMTP id va2so6505730obc.12
        for <netdev@vger.kernel.org>; Tue, 15 Oct 2013 14:38:52 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.03.1310152242170.1919@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ok, thanks for the clarification.

On Tue, Oct 15, 2013 at 1:36 PM, Julian Anastasov <ja@ssi.bg> wrote:
>
>         Hello,
>
> On Tue, 15 Oct 2013, Vincent Li wrote:
>
>> it is strange though when 10.1.1.9 is unreachable address and the ping
>> utility reports error 'Destination Host Unreachable' with source
>> 10.1.1.1.  before 2.6.37, it reports 10.1.1..2
>
>         I see, it is the icmp_send() function that uses
> inet_select_addr() to select primary source for locally generated
> ICMP errors that are sent back to the sender (10.1.1.2).
> In your case it is the error_report from the ARP code.
>
>         So, you are correct about the commit but I don't
> see any problem with this behavior. IIRC, users preferred
> to see primary addresses in the traceroute output.
>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>
