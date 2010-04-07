From: =?UTF-8?B?0JDQvdC00YDQtdC5INCT0YDQuNCz0L7RgNGM0LXQsg==?=
	<andrew@ei-grad.ru>
Subject: GSoC Idea - Ability to extend a XML output for the conntrack netlink
 interface
Date: Thu, 08 Apr 2010 04:23:21 +0600
Message-ID: <4BBD05D9.4010902@ei-grad.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f223.google.com ([209.85.220.223]:50538 "EHLO
	mail-fx0-f223.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752271Ab0DGWXZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Apr 2010 18:23:25 -0400
Received: by fxm23 with SMTP id 23so1546007fxm.21
        for <netdev@vger.kernel.org>; Wed, 07 Apr 2010 15:23:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA256

Hello!

My name is Andrey Grigorev, or just Andrew, and I am a 5th year
student of Computer Science in Chelyabinsk State University, Russia.

In summary, my idea is to explore and implement a method for adding to
the XML output of netlink interface of conntrack an additional
information about connections. This can be useful, for example, to get
a list of popular web resources (by grabbing the Host header from HTTP
requests), without using a proxy server. Of course, I understand that
for this particular purpose, a usual proxy server is better solution,
than a kernel-based one :-).

But just imagine - the kernel and user services can transparently
receive information from many protocols, without the use of any gears
similar to the proxy server. With that modules it is possible to
maintain statistics on a completely different user accounts. You can
get expected volume of traffic for the connection and take it into
account in the packets queue scheduler or make routing decision based
on it. Keep a record of IP telephony and similar services without the
use of AAA server and without the need for client authentication.

Of course, not every protocol can be parsed in such way, many
protocols using compression and encryption. But in most cases, even
for transferring files and media content we will have its profit.

Perhaps such a mechanism is devised, and even implemented? I am
interested to know what the developers of kernel networking, think
about this project. I would be very glad if someone agreed to be a
mentor. In fact, there are a GSoC ideas more crazy than mine... :-)

So, what exactly I would like to make in the GSoC project:

1. Explore, document and implement a method for adding to the XML
output of netlink interface of conntrack an additional information
about connections.

2. Implement the conntrack module for the HTTP protocol, which yields
Host and Content-Length headers and URI path for HTTP connections
tracked in conntrack.

3. =D0=90dd an ability to output similar information for protocols with
existing NAT helper modules:
- - ftp, user name and size of files transferred accross the connection
- - h323 and sip, user name and information about codecs

Sincerely, Andrew Grigorev.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iF4EAREIAAYFAku9BdgACgkQF7Tfq9FitO70MQD/dIszGQo+RlVnt3tB73VvOLE2
4JbVcwMwnsiDG42aWF0A/2urdFvU1UFBVFWlZMxus/MqTqXG+S9MzFXp+9uKAb93
=3Dw7DW
-----END PGP SIGNATURE-----

