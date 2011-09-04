From: "Yan, Zheng" <zheng.z.yan@linux.intel.com>
Subject: Re: [PATCH -next v2] unix stream: Fix use-after-free crashes
Date: Sun, 4 Sep 2011 16:23:02 +0800
Message-ID: <CAAM7YAk0csJLLVFF6KYA8vMG_BN6QDvmYvtnY0Sq7P=cBsuKfg@mail.gmail.com>
References: <4E631032.6050606@intel.com>
	<CA+icZUU25QMMCVT1VfF9XB0wrkppNmKQbHwoHDAQ-qV9bi+HqQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"sfr@canb.auug.org.au" <sfr@canb.auug.org.au>,
	"tim.c.chen@linux.intel.com" <tim.c.chen@linux.intel.com>,
	"jirislaby@gmail.com" <jirislaby@gmail.com>
To: sedat.dilek@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:41856 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752610Ab1IDIXF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Sep 2011 04:23:05 -0400
Received: by vxi9 with SMTP id 9so3136028vxi.19
        for <netdev@vger.kernel.org>; Sun, 04 Sep 2011 01:23:03 -0700 (PDT)
In-Reply-To: <CA+icZUU25QMMCVT1VfF9XB0wrkppNmKQbHwoHDAQ-qV9bi+HqQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 4, 2011 at 3:12 PM, Sedat Dilek <sedat.dilek@googlemail.com=
> wrote:
> On Sun, Sep 4, 2011 at 7:44 AM, Yan, Zheng <zheng.z.yan@intel.com> wr=
ote:
>> Commit 0856a30409 (Scm: Remove unnecessary pid & credential referenc=
es
>> in Unix socket's send and receive path) introduced a use-after-free =
bug.
>> It passes the scm reference to the first skb. Skb(s) afterwards may
>> reference freed data structure because the first skb can be destruct=
ed
>> by the receiver at anytime. The fix is by passing the scm reference =
to
>> the very last skb.
>>
>
> s/by passing/bypassing ?

No

>
>> Signed-off-by: Zheng Yan <zheng.z.yan@intel.com>
>> Reported-by: Jiri Slaby <jirislaby@gmail.com>
>> ---
>
> Tested on i386 against linux-next (next-20110831).
>

Thank you.

> - Sedat -
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
