From: kuznet@ms2.inr.ac.ru
Subject: Re: [PATCH] connect() return value.
Date: Mon, 12 Aug 2002 05:28:38 +0400 (MSD)
Sender: owner-netdev@oss.sgi.com
Message-ID: <200208120128.FAA16791@sex.inr.ac.ru>
References: <20020811232546.GA27168@anakin.wychk.org>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: glee@gnupilgrims.org (Geoffrey Lee)
In-Reply-To: <20020811232546.GA27168@anakin.wychk.org> from "Geoffrey Lee" at Aug 12, 2 09:25:46 am
List-Id: netdev.vger.kernel.org

Hello!

>					     I wanted to know what 
> is the "correct" behavior for connect() by default with signal().

This simply does not matter, that's answer.

Actually, it is not so easy to implement restartable connect().
I think this is the only reason why it not restartable in some OSes.

BTW could you make the following experiments on the same OSes:
connect() on nonblocking socket, then repeat the connect()
until it returns EISCONN. I guess the behaviour also will be different.


> it should be trivial to hand edit my prevoius patch posted.

Yes, of course. Though the first part of it also from the class
"does not matter", it is worth to do this just for sanity.

Alexey
