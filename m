From: kuznet@ms2.inr.ac.ru
Subject: Re: PATCH Re: udp weirdness
Date: Tue, 1 Oct 2002 17:53:13 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200210011353.RAA19504@sex.inr.ac.ru>
References: <Pine.GSO.4.30.0209302017330.16713-100000@shell.cyberus.ca>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.CA (jamal)
In-Reply-To: <Pine.GSO.4.30.0209302017330.16713-100000@shell.cyberus.ca> from "jamal" at Oct 1, 2 04:45:01 am
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> be propagated back to the socket level; please review and probably
> apply:

That was tried and failed miserably ages ago. Applications become
insane when getting this error from logging tons of useless messages
to abort()ing and cpu hogging. From the other hand silent reaction
to loss is almost exactly desired behaviour in presence of congestion
in the most of cases.

I have no idea, why that OSes work. Probably, they are so great that
never lose packets. We do. 

Probably, the world has changed since that time, but I have no desire
to repeat the experiment to be honest.

Alexey
