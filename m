From: Paul Bolle <pebolle@tiscali.nl>
Subject: [PATCH 0/1] ser_gigaset: use container_of() instead of detour
Date: Thu, 18 Feb 2016 21:29:07 +0100
Message-ID: <1455827348-8574-1-git-send-email-pebolle@tiscali.nl>
Cc: Dmitry Vyukov <dvyukov@google.com>,
	=?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Martin Wilck <Martin.Wilck@ts.fujitsu.com>,
	Jarkko Sakkinen <jarkko.sakkinen@linux.intel.com>,
	Tilman Schmidt <tilman@imap.cc>, linux-kernel@vger.kernel.org,
	gigaset307x-common@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dmitry Vyukov reported that the syzkaller fuzzer uncovered a leak in
ser_gigaset (see
https://lkml.kernel.org/g/CACT4Y+Y+P7-pM0D4HTz4ZF6i+Rya22eOkPdnrv_OmDCMB7eQtg@mail.gmail.com).
This small patch fixes that. The commit explanation contains all the details to
understand how this leak made its way into the code.

This should eventually land in stable. No fixes tag because backporting is
probably not so straightforward for v4.3 and earlier. So I suggest I'll send
proper backports in about two weeks.

Paul Bolle (1):
  ser_gigaset: use container_of() instead of detour

 drivers/isdn/gigaset/ser-gigaset.c | 9 +--------
 1 file changed, 1 insertion(+), 8 deletions(-)

-- 
2.4.3
