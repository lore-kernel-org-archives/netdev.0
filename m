From: Gabriel C <nix.or.die@googlemail.com>
Subject: net/ipv4/inetpeer.c stack warnings
Date: Thu, 19 Jul 2007 14:29:53 +0200
Message-ID: <469F5941.7090900@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1763394AbXGSMbb@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello ,

I noticed on current git this warning in net/ipv4/inetpeer.c

...

  CC      net/ipv4/inetpeer.o
net/ipv4/inetpeer.c: In function 'unlink_from_pool':
net/ipv4/inetpeer.c:297: warning: the address of 'stack' will always
evaluate as 'true'
net/ipv4/inetpeer.c:297: warning: the address of 'stack' will always
evaluate as 'true'
net/ipv4/inetpeer.c: In function 'inet_getpeer':
net/ipv4/inetpeer.c:409: warning: the address of 'stack' will always
evaluate as 'true'
net/ipv4/inetpeer.c:409: warning: the address of 'stack' will always
evaluate as 'true'


...

Regards,

Gabriel C
