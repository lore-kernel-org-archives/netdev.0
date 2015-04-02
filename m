From: Josh Boyer <jwboyer@fedoraproject.org>
Subject: commit d0af71a3573 for 3.19.y stable
Date: Wed, 1 Apr 2015 20:34:22 -0400
Message-ID: <CA+5PVA5oNEWJbU+VdG1rP+tbT1q55W2MSe3afOHP3bcP2h660A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Greg KH <gregkh@linuxfoundation.org>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

Another possible stable candidate.  We had a report[1] of deadlocks
with tigon devices on 3.19.y and the commit below fixes it.  It
cherry-picks cleanly on top of 3.19.3.  I don't see it queued up so I
thought I would point it out.

commit d0af71a3573f1217b140c60b66f1a9b335fb058b
Author: Jun'ichi Nomura \(NEC\) <j-nomura@ce.jp.nec.com>
Date:   Thu Feb 12 01:26:24 2015 +0000

    tg3: Hold tp->lock before calling tg3_halt() from tg3_init_one()

josh

[1] https://bugzilla.redhat.com/show_bug.cgi?id=1207789
