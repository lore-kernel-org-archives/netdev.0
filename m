From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next 1/6] GRE: Use RTNL for atomic protocol registration.
Date: Thu, 14 Mar 2013 20:37:16 -0700
Message-ID: <CALnjE+oJKL5EwaEhbScyfVZtcfXNS_BqJdnA2+f6OXtkPz7aDg@mail.gmail.com>
References: <1363214907-3257-1-git-send-email-pshelar@nicira.com>
	<CAHXqBFJzomhYjQvF+3+aNRjpZzByu-U=s5rGVnxwyL+6vemPTw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, stephen@networkplumber.org,
	netdev@vger.kernel.org, jesse@nicira.com
To: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog108.obsmtp.com ([74.125.149.199]:52965 "HELO
	na3sys009aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753114Ab3CODhR convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Mar 2013 23:37:17 -0400
Received: by mail-ye0-f199.google.com with SMTP id j12so4053921yeg.2
        for <netdev@vger.kernel.org>; Thu, 14 Mar 2013 20:37:17 -0700 (PDT)
In-Reply-To: <CAHXqBFJzomhYjQvF+3+aNRjpZzByu-U=s5rGVnxwyL+6vemPTw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 13, 2013 at 4:22 PM, Micha=C5=82 Miros=C5=82aw <mirqus@gmai=
l.com> wrote:
> 2013/3/13 Pravin B Shelar <pshelar@nicira.com>:
>> Currently gre demultiplexer uses its own spin-lock. We should
>> rather RTNL lock.
> [...]
>> +       rtnl_lock();
>>         err =3D gre_add_protocol(&gre_pptp_protocol, GREPROTO_PPTP);
>> +       rtnl_unlock();
>
> Why not keep lock/unlock inside gre_add/del_protocol()?
>
As Stephen suggested I am planning on dropping this patch.
