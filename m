From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: inet_csk_get_port lock imbalance?
Date: Thu, 18 Jun 2009 16:23:37 +0200
Message-ID: <4A3A4DE9.1050607@gmail.com>
References: <4A3A476A.1060808@gmail.com> <20090618141425.GA31266@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f213.google.com ([209.85.218.213]:54614 "EHLO
	mail-bw0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752011AbZFROXf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 10:23:35 -0400
Received: by bwz9 with SMTP id 9so1107425bwz.37
        for <netdev@vger.kernel.org>; Thu, 18 Jun 2009 07:23:37 -0700 (PDT)
In-Reply-To: <20090618141425.GA31266@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/18/2009 04:14 PM, Florian Westphal wrote:
> Jiri Slaby <jirislaby@gmail.com> wrote:
>> we've found a weird locking discipline in inet_csk_get_port. Who is
>> supposed to unlock the spin lock in the place marked in the code below?
> I'd appreciate it if you consider the above a blatant lie and check it again :-)

Yes, you are right, I went through 'if (remaining <= 0) {' branch
through which it can't go. Thanks.
