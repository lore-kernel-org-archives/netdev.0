From: Berge Schwebs =?utf-8?Q?Bj=C3=B8rlo?= <berge@trivini.no>
Subject: Re: [BUG] ipv6 and TSO on GRE is broken
Date: Thu, 2 May 2013 10:32:45 +0200
Message-ID: <20130502083245.GD31654@trivini.no>
References: <1367423622.11020.54.camel@edumazet-glaptop>
 <CALnjE+pPmsJx6zqcA7PnR3GX3HUrrtCbZyqj7nyEDBCv9_Tntw@mail.gmail.com>
 <CALnjE+pvvHccEZZhH9ejCk4XGeTnWjupAFNfxvSAGdrOpHWhkg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	"Steinar H. Gunderson" <sesse@google.com>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassarossa.samfundet.no ([193.35.52.29]:44400 "EHLO
	cassarossa.samfundet.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756918Ab3EBJDN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 May 2013 05:03:13 -0400
Content-Disposition: inline
In-Reply-To: <CALnjE+pvvHccEZZhH9ejCk4XGeTnWjupAFNfxvSAGdrOpHWhkg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 02, 2013 at 01:00:54AM -0700, Pravin Shelar wrote:
> On Thu, May 2, 2013 at 12:02 AM, Pravin Shelar <pshelar@nicira.com> w=
rote:
>> I forgot to add gre gso handler to inet6 offloads list.
>>
>> I will send out patch soon.
> nevermind, I guess you were talking abt ipv6 over gre-ipv4 device, I =
will
> check the code.

I'm not sure if we're talking about the same issue, but I'm experiencin=
g
massive packet drops with outbound IPv6 traffic with a GREv4 tunnel wit=
h IPv6
traffic on the inside. Inbound traffic seems fine, and IPv4 inside the =
tunnel
is fine in both directions.

=46irst observed when upgrading to 3.9 the other day. 3.8 was fine. git=
 bisect
and a kernel-recompile-reboot-dance points to commit
68c331631143f5f039baac99a650e0b9e1ea02b6 as the culprit.

Cheers,
-Berge

--=20
Berge Schwebs Bj=C3=B8rlo
Alegr=C3=ADa!
