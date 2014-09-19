From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] macvlan: allow to enqueue broadcast pkt on virtual
 device
Date: Fri, 19 Sep 2014 16:09:32 -0700
Message-ID: <1411168172.26859.61.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1410941288-1880-1-git-send-email-nicolas.dichtel@6wind.com>
	 <CAHA+R7OQ=R8Y0LDVormukRjdosODiRuGq+NTrZQ08sXvfJYUnQ@mail.gmail.com>
	 <1411162501.26859.39.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHA+R7M=Wp1u1hXD9YE52Ct74KOovEaVjCECV_5EsrAO_rJ7ag@mail.gmail.com>
	 <1411164317.26859.45.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHA+R7M-HKbCmX3kEPLGrNjh+qF-OnL+V8C2biFBz24_7VOsxw@mail.gmail.com>
	 <1411166670.26859.48.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHA+R7MxiP9gZe2daJunXOKNa6sQd9JZ_4_ko6ipYGtshVP0bg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:34433 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752139AbaISXJe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 19:09:34 -0400
Received: by mail-pd0-f177.google.com with SMTP id fp1so804973pdb.36
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2014 16:09:34 -0700 (PDT)
In-Reply-To: <CAHA+R7MxiP9gZe2daJunXOKNa6sQd9JZ_4_ko6ipYGtshVP0bg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-09-19 at 15:57 -0700, Cong Wang wrote:
> On Fri, Sep 19, 2014 at 3:44 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >
> > Therefore, suggesting user to 'fix tx_queue_len' is totally wrong.
> 
> How about HTB? You said:
> 
> "Only when you want to have say HTB on the bonding, you might need to
> change tx_queue_len"

Again, what is your point ?

How is it relevant to this particular bug report ?

Don't you think people using HTB on a virtual device do not already know
its better to either :

- Not use the default pfifo on htb classes
- Increase device queue len on the device.

Its been like that since a decade. No changes are needed in bond driver.
