From: kuznet@ms2.inr.ac.ru
Subject: Re: off by one error in 3des cbc keying
Date: Mon, 11 Nov 2002 20:18:55 +0300 (MSK)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200211111718.UAA27829@sex.inr.ac.ru>
References: <20021111100109.GB18677@outpost.ds9a.nl>
Mime-Version: 1.0
Cc: davem@redhat.com, gem@asplinux.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ahu@ds9a.nl (bert hubert)
In-Reply-To: <20021111100109.GB18677@outpost.ds9a.nl> from "bert hubert" at Nov 11, 2 11:01:09 am
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> [alexey's nameserver is off, cc to netdev@oss.sgi.com, perhaps he sees it
> there]

Unlikely. I think while our network is down list exploders just
drop mails unlike normal mail agents. :-)


> I wonder, is 'incoming bypass' implemented yet?

It is. But your example shows that something is wrong there. Fix will follow
later.


> Key refreshing/updating doesn't appear to work either, after they key has
> expired, all bets are off.

What does happen in logs/setkey -D? Actually, before sending previous
large patch dealing with expire timers I got it to the point where keys
are refreshed nicely at _one_ side, another required reboot and the test
was not accomplished.

Alexey
