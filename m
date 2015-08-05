From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: rtnl_mutex deadlock?
Date: Wed, 5 Aug 2015 10:44:51 +0200
Message-ID: <CA+55aFw1856zEq88RfqoizjeVRR9Ut-ug+VWA+mKFOS77FYpSg@mail.gmail.com>
References: <CA+55aFwYhdHdLUbYYAc9GgmFuVXniwAESYHuzDWjdapPC0m1Xw@mail.gmail.com>
	<CAHA+R7N2fRz2zr-6MX9StqPLdNAWRiG55xidrC7reSRrVeQPcQ@mail.gmail.com>
	<20150805074330.GA2084@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <cwang@twopensource.com>,
	David Miller <davem@davemloft.net>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Thomas Graf <tgraf@suug.ch>, Scott Feldman <sfeldma@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Network Development <netdev@vger.kernel.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:35589 "EHLO
	mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751771AbbHEIov (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2015 04:44:51 -0400
Received: by iodd187 with SMTP id d187so42435633iod.2
        for <netdev@vger.kernel.org>; Wed, 05 Aug 2015 01:44:51 -0700 (PDT)
In-Reply-To: <20150805074330.GA2084@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 5, 2015 at 9:43 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>
> Indeed. Most probably, NETLINK_CB(skb).portid got zeroed.
>
> Linus, are you able to reproduce this or is it a one-time issue?

I don't think I'm able to reproduce this, it's happened only once so far.

                 Linus
