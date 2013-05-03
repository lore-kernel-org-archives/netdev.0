From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [BUG] ipv6 and TSO on GRE is broken
Date: Thu, 2 May 2013 19:17:57 -0700
Message-ID: <CALnjE+qn8oaczOu0rRwcxhdmhaPSzVJgdhQ7un6yQC7og=fknQ@mail.gmail.com>
References: <1367423622.11020.54.camel@edumazet-glaptop>
	<CALnjE+pPmsJx6zqcA7PnR3GX3HUrrtCbZyqj7nyEDBCv9_Tntw@mail.gmail.com>
	<CALnjE+pvvHccEZZhH9ejCk4XGeTnWjupAFNfxvSAGdrOpHWhkg@mail.gmail.com>
	<20130502083245.GD31654@trivini.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	"Steinar H. Gunderson" <sesse@google.com>
To: =?ISO-8859-1?Q?Berge_Schwebs_Bj=F8rlo?= <berge@trivini.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog104.obsmtp.com ([74.125.149.73]:58227 "HELO
	na3sys009aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755954Ab3ECCSE convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 May 2013 22:18:04 -0400
Received: by mail-ye0-f197.google.com with SMTP id q11so1780882yen.0
        for <netdev@vger.kernel.org>; Thu, 02 May 2013 19:17:57 -0700 (PDT)
In-Reply-To: <20130502083245.GD31654@trivini.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 2, 2013 at 1:32 AM, Berge Schwebs Bj=F8rlo <berge@trivini.n=
o> wrote:
> On Thu, May 02, 2013 at 01:00:54AM -0700, Pravin Shelar wrote:
>> On Thu, May 2, 2013 at 12:02 AM, Pravin Shelar <pshelar@nicira.com> =
wrote:
>>> I forgot to add gre gso handler to inet6 offloads list.
>>>
>>> I will send out patch soon.
>> nevermind, I guess you were talking abt ipv6 over gre-ipv4 device, I=
 will
>> check the code.
>
> I'm not sure if we're talking about the same issue, but I'm experienc=
ing
> massive packet drops with outbound IPv6 traffic with a GREv4 tunnel w=
ith IPv6
> traffic on the inside. Inbound traffic seems fine, and IPv4 inside th=
e tunnel
> is fine in both directions.
>
> First observed when upgrading to 3.9 the other day. 3.8 was fine. git=
 bisect
> and a kernel-recompile-reboot-dance points to commit
> 68c331631143f5f039baac99a650e0b9e1ea02b6 as the culprit.
>
Thanks,
I posted fix on netdev.
