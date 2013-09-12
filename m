From: Hong zhi guo <honkiko@gmail.com>
Subject: Re: [PATCH net-next] fix NULL pointer dereference in br_handle_frame
Date: Fri, 13 Sep 2013 00:18:02 +0800
Message-ID: <CAA7+ByUy5jL2hpkN+GBDRCXh_GM7qnS58iZvgp1RxZmoAqj+bQ@mail.gmail.com>
References: <1378988195-2710-1-git-send-email-zhiguohong@tencent.com>
	<1379001428-2727-1-git-send-email-zhiguohong@tencent.com>
	<CAA7+ByXUnTi1+-yreK+q03Cbqg+FM7DTfQ9qXbyRbZ0N508JBQ@mail.gmail.com>
	<1379002315.24408.19.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: vyasevic@redhat.com, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, Hong Zhiguo <zhiguohong@tencent.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f175.google.com ([209.85.216.175]:49481 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753577Ab3ILQSD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 12:18:03 -0400
Received: by mail-qc0-f175.google.com with SMTP id v2so13474qcr.20
        for <netdev@vger.kernel.org>; Thu, 12 Sep 2013 09:18:02 -0700 (PDT)
In-Reply-To: <1379002315.24408.19.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sorry, Eric, maybe I'm using wrong words. Thanks for your review and help.
So you both prefer not testing IFF_BRIDGE_PORT. Let's take the new fix.

On Fri, Sep 13, 2013 at 12:11 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2013-09-13 at 00:06 +0800, Hong zhi guo wrote:
>> You're right, Vlad.
>> One thing is missing in Eric's fix, NULL dereference is still possible
>> in br_handle_local_finish. Above is the new version of fix.
>
> Hey, it was not a 'fix', but a comment on your patch and bridge
> defensive programming.
>
>
>



-- 
best regards
Hong Zhiguo
