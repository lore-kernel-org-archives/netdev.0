From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH 2/2] net: wireless: fix to uses struct
Date: Wed, 21 Dec 2016 23:33:45 +0100
Message-ID: <1482359625.28171.2.camel@tiscali.nl>
References: <608881482358981@web17g.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Thomas Gleixner <tglx@linutronix.de>,
        linux-wireless <linux-wireless@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>
To: Ozgur Karatas <okaratas@member.fsf.org>,
        johannes <johannes@sipsolutions.net>,
        David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <608881482358981@web17g.yandex.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-12-22 at 00:23 +0200, Ozgur Karatas wrote:
> I compiled and didn't to errors.

Really?

$ make net/wireless/reg.o
  CHK     include/config/kernel.release
  CHK     include/generated/uapi/linux/version.h
  CHK     include/generated/utsrelease.h
  CHK     include/generated/bounds.h
  CHK     include/generated/timeconst.h
  CHK     include/generated/asm-offsets.h
  CALL    scripts/checksyscalls.sh
  CC      net/wireless/reg.o
net/wireless/reg.c: In function ‘regulatory_hint_core’:
net/wireless/reg.c:2294:28: error: ‘regulatory_request’ undeclared (first use in this function)
  request = kzalloc(sizeof(*regulatory_request), GFP_KERNEL);
                            ^~~~~~~~~~~~~~~~~~
net/wireless/reg.c:2294:28: note: each undeclared identifier is reported only once for each function it appears in
net/wireless/reg.c: In function ‘regulatory_hint_user’:
net/wireless/reg.c:2316:28: error: ‘regulatory_request’ undeclared (first use in this function)
  request = kzalloc(sizeof(*regulatory_request), GFP_KERNEL);
                            ^~~~~~~~~~~~~~~~~~
net/wireless/reg.c: In function ‘regulatory_hint’:
net/wireless/reg.c:2388:28: error: ‘regulatory_request’ undeclared (first use in this function)
  request = kzalloc(sizeof(*regulatory_request), GFP_KERNEL);
                            ^~~~~~~~~~~~~~~~~~
scripts/Makefile.build:293: recipe for target 'net/wireless/reg.o' failed
make[1]: *** [net/wireless/reg.o] Error 1
Makefile:1640: recipe for target 'net/wireless/reg.o' failed
make: *** [net/wireless/reg.o] Error 2 

Didn't Thomas Gleixner suggest that you do a basic C course just yesterday?


Paul Bolle
