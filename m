From: Neal Cardwell <ncardwell@google.com>
Subject: Re: Invalid timestamp? causing tight ack loop (hundreds of thousands
 of packets / sec)
Date: Mon, 9 Feb 2015 10:42:24 -0500
Message-ID: <CADVnQym7kQ-NutJrKHJ=upmfXUAg1+NTkSh4tSsi2EsbyeQNyw@mail.gmail.com>
References: <CAO-X30uMA7=DTm5KqqvYC5RVTM0bg9pKBO1nX1+6x_2pF_fWfA@mail.gmail.com>
	<1423036986.907.105.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAO-X30shOhH7tN+msRvbLreeUvZesKARqyU0Lnm3_xoeea9uaQ@mail.gmail.com>
	<1423052431.907.112.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAO-X30umnbpQG9mwj67ZUkxQpVcGgMMsP8SqY=_3ZeoTczjbmQ@mail.gmail.com>
	<1423181871.31870.94.camel@edumazet-glaptop2.roam.corp.google.com>
	<CADVnQyn20vWgfujSRRc+thud75hz0c1HG+vFEPhAu24c4-KivA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Avery Fay <avery@mixpanel.com>, Netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f42.google.com ([209.85.216.42]:43136 "EHLO
	mail-qa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933101AbbBIPmZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2015 10:42:25 -0500
Received: by mail-qa0-f42.google.com with SMTP id dc16so21570485qab.1
        for <netdev@vger.kernel.org>; Mon, 09 Feb 2015 07:42:24 -0800 (PST)
In-Reply-To: <CADVnQyn20vWgfujSRRc+thud75hz0c1HG+vFEPhAu24c4-KivA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 6, 2015 at 4:16 PM, Neal Cardwell <ncardwell@google.com> wrote:
> On Thu, Feb 5, 2015 at 7:17 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> On Thu, 2015-02-05 at 15:25 -0800, Avery Fay wrote:
>>
>>> Are these available anywhere? Or could they be made available? This
>>> seems like a much better solution than disabling timestamps.

These are now in the "net-next" tree:

f06535c Merge branch 'tcp_ack_loops'
4fb17a6 tcp: mitigate ACK loops for connections as tcp_timewait_sock
f2b2c58 tcp: mitigate ACK loops for connections as tcp_sock
a9b2c06 tcp: mitigate ACK loops for connections as tcp_request_sock
032ee42 tcp: helpers to mitigate ACK loops by rate-limiting
out-of-window dupacks

neal
