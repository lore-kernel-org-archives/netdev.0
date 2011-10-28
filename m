From: Daniel Baluta <daniel.baluta@gmail.com>
Subject: Re: [RFC] tcp: Export TCP Delayed ACK parameters to user
Date: Fri, 28 Oct 2011 11:01:51 +0300
Message-ID: <CAEnQRZAj4H9neNsGB8hkrQO5trvP8QimhKhpnwchjTVrAo2LGQ@mail.gmail.com>
References: <1319756841-2051-1-git-send-email-dbaluta@ixiacom.com>
	<1319760097.19125.55.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:56526 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932085Ab1J1IBw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2011 04:01:52 -0400
Received: by qabj40 with SMTP id j40so3411232qab.19
        for <netdev@vger.kernel.org>; Fri, 28 Oct 2011 01:01:51 -0700 (PDT)
In-Reply-To: <1319760097.19125.55.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 28, 2011 at 3:01 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le vendredi 28 octobre 2011 =E0 02:07 +0300, Daniel Baluta a =E9crit =
:
>> RFC2581 ($4.2) specifies when an ACK should be generated as follows:
>>
>> " .. an ACK SHOULD be generated for at least every second
>> =A0 full-sized segment, and MUST be generated within 500 ms
>> =A0 of the arrival of the first unacknowledged packet.
>> "
>>
>> We export the number of segments and the timeout limits
>> specified above, so that a user can tune them according
>> to its needs.
>>
>
> Well, this requires user has a machine exclusive use :)

So, this means that setting parameters system wide
isn't an option?

On Windows there is a global setting TcpAckFrequency [1],
which is similar with our tcp_delack_{min,max}.

On Solaris there is a global option tcp_deferred_acks_max [2],
which is similar with our tcp_delack_segs.

Thanks for your comments, I will post an updated patch asap.

Daniel.

[1] http://support.microsoft.com/kb/328890
[2] http://www.sean.de/Solaris/soltune.html
