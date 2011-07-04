From: jamal <hadi@cyberus.ca>
Subject: Re: libpcap and tc filters
Date: Mon, 04 Jul 2011 07:11:48 -0400
Message-ID: <1309777908.26180.1.camel@mojatatu>
References: <CAA0qwj6fWJFVCDW9M9jZhvQnSTy=Pnyp0AhWFYT8FOiroq7C=Q@mail.gmail.com>
Reply-To: jhs@mojatatu.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Adam Katz <adamkatz0@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:43924 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752364Ab1GDLL6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2011 07:11:58 -0400
Received: by iwn6 with SMTP id 6so4363793iwn.19
        for <netdev@vger.kernel.org>; Mon, 04 Jul 2011 04:11:58 -0700 (PDT)
In-Reply-To: <CAA0qwj6fWJFVCDW9M9jZhvQnSTy=Pnyp0AhWFYT8FOiroq7C=Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Capture tcpdump for both scenario that works and one
that doesnt.
Make sure the filters match your failing scenario.

cheers,
jamal

On Mon, 2011-07-04 at 10:38 +0300, Adam Katz wrote:
> Hi Everyone
> 
> I'm sorry for littering the mailing list with this question, but no
> other place could help me..
> 
> I'm attempting to use tc to shape traffic sent using libpcap, I'm
> doing this for a research project. I have a classful scheduler with
> several classes, to this scheduler I attach a few filters based on
> destination tcp ports.
> 
> My problem is this: When sending packets using a normal userland
> socket, the filters work and I see the appropriate traffic entering
> the right class. BUT when sending packets with libpcap, all packets
> end up in the scheduler's default band as if the filters simply refuse
> to work.
> 
> Can anyone suggest a solution?
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


