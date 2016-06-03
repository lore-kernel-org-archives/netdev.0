From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: accept RST if SEQ matches right edge of
 SACK block
Date: Fri, 03 Jun 2016 08:13:56 -0700
Message-ID: <1464966836.5939.189.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1464694717-22548-1-git-send-email-pau.espin@tessares.net>
	 <1464796118.5939.156.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CALCp7mne5OEU1hT-XHoQR33S7tzCRuDMzCu-deXx18QbdBgmYA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: Pau Espin <pau.espin@tessares.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:35537 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751312AbcFCPOB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 11:14:01 -0400
Received: by mail-pa0-f65.google.com with SMTP id gp3so6200099pac.2
        for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 08:14:00 -0700 (PDT)
In-Reply-To: <CALCp7mne5OEU1hT-XHoQR33S7tzCRuDMzCu-deXx18QbdBgmYA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-06-03 at 14:16 +0200, Pau Espin wrote:
> I will provide a new patch as soon as I find some time to do it.
> 
> Indeed, I think there is no need to check duplicate_sack, I will remove it.
> 
> I will also update the description.
> 
> Shall I also add a sysctl to disable this patch and still be able to
> stick strictly to RFC 5961 3.2 for the checks?

I have no strict opinion on this.

It seems to me that checking at most 4 right edges (at least in current
linux implementation) is not adding a huge risk, and allows for better
interoperability.

I vote for no extra sysctl.
