From: kuznet@ms2.inr.ac.ru
Subject: Re: [PATCH] connect() return value.
Date: Tue, 13 Aug 2002 08:44:21 +0400 (MSD)
Sender: owner-netdev@oss.sgi.com
Message-ID: <200208130444.IAA20082@sex.inr.ac.ru>
References: <20020813022115.GA11627@anakin.wychk.org>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: glee@gnupilgrims.org (Geoffrey Lee)
In-Reply-To: <20020813022115.GA11627@anakin.wychk.org> from "Geoffrey Lee" at Aug 13, 2 12:21:15 pm
List-Id: netdev.vger.kernel.org

Hello!

> it returns -EISCONN. This behavior is consistent in all operating
> systems which I have tested, which include the following:

This is very strange. Linux should return success once.

Probably, I should explain why I ask this. This is a necessary
element of implementation of restartable connect(). If connect()
is restarted after signal, it should return success on connected
socket sometimes rather than -EISCONN.


> On Linux (v 2.4.18):
> 
> read() returns 0 with an errno of 115. On Linux 115 corresponds to 
> -EINPROGRESS.

I am sorry, this machine is not running Linux.

Zero length read() always returns zero, not depending of socket state.



> Yep. Though I would really like it if it conforms to what the rest of 
> the Unices does with that behavior.

Non-sense. We are not going to emulate pathological cases.


> So, we can agree

Did we argue about this? :-)

Alexey
