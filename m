From: Takashi Hibi <hibi665@oki.com>
Subject: ping6 error
Date: Wed, 21 Apr 2004 15:08:32 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040421150832.1f1dcde9%hibi665@oki.com>
Mime-Version: 1.0
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi all,

There are IPv6 addresses for which ping6 doesn't work.
The host has a global IPv6 address.

$ ping6 ff05::1    (site-local multicast address)
connect: Cannot assign requested address
$ ping6 fec0::1    (site-local address)
connect: Cannot assign requested address

Usagi kernel doesn't have this problem.
Is this an expected behavior? And why this happens?

Regards,
Takashi Hibi
