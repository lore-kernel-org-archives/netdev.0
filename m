From: kuznet@ms2.inr.ac.ru
Subject: Re: Patch: Idea for RFC2863 conform OperStatus
Date: Mon, 14 Oct 2002 02:04:22 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200210132204.CAA09385@sex.inr.ac.ru>
References: <Pine.GSO.4.30.0210131726010.26803-100000@shell.cyberus.ca>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca (jamal)
In-Reply-To: <Pine.GSO.4.30.0210131726010.26803-100000@shell.cyberus.ca> from "jamal" at Oct 13, 2 05:34:03 pm
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> Actually the extra flags are only valid when IFF_RUNNING is not set.

Even so...

Well, then I am inclined not to agree to give even one of those valuable
16 spare bits for this. :-)

I cannot imagine how much should I drink to consider states descibed
in this rfc as a valid abstraction. Device can be working and can be dead
by thousands of reasons. The best which I can propose is to show a string
somewhere in /proc (well, or as a _string_ attribute in RTM_NEWLINK),
explaining why device is not alive and let snmpd to translate this string
to these bogus states to generate traps.

Alexey
