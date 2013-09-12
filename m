From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] fix NULL pointer dereference in br_handle_frame
Date: Thu, 12 Sep 2013 09:11:55 -0700
Message-ID: <1379002315.24408.19.camel@edumazet-glaptop>
References: <1378988195-2710-1-git-send-email-zhiguohong@tencent.com>
	 <1379001428-2727-1-git-send-email-zhiguohong@tencent.com>
	 <CAA7+ByXUnTi1+-yreK+q03Cbqg+FM7DTfQ9qXbyRbZ0N508JBQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, Hong Zhiguo <zhiguohong@tencent.com>
To: Hong zhi guo <honkiko@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:55815 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753913Ab3ILQL6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 12:11:58 -0400
Received: by mail-pa0-f48.google.com with SMTP id kp13so1295711pab.21
        for <netdev@vger.kernel.org>; Thu, 12 Sep 2013 09:11:57 -0700 (PDT)
In-Reply-To: <CAA7+ByXUnTi1+-yreK+q03Cbqg+FM7DTfQ9qXbyRbZ0N508JBQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-09-13 at 00:06 +0800, Hong zhi guo wrote:
> You're right, Vlad.
> One thing is missing in Eric's fix, NULL dereference is still possible
> in br_handle_local_finish. Above is the new version of fix.

Hey, it was not a 'fix', but a comment on your patch and bridge
defensive programming.
