From: Carl-Daniel Hailfinger <c-d.hailfinger.kernel.2003@gmx.net>
Subject: forcedeth: version 0.20 available
Date: Tue, 23 Dec 2003 01:43:04 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FE78F98.4040304@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Manfred Spraul <manfred@colorfullife.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello all,

version 0.20 of forcedeth (GPLed nvnet replacement for nForce
on-board nics) for Linux 2.4 and 2.6 is available at
http://www.hailfinger.org/carldani/linux/patches/forcedeth/
It is also integrated in current -mm patchset and the 2.6
experimental net driver queue.
I will make precompiled modules available at the above address
as time permits.

Fixes in this release over 0.18:
* Work around bogus MAC addresses. Please report your exact
  hardware version/manufacturer if you hit this issue since
  NVidia has stated this should never happen and they are
  interested in any cases where it happens.
* Under extremely high network load on nForce3 systems, the
  nic won't lock up or slow down any more.

Known issues:
* Some nForce versions will report every received packet as
  1500 bytes long and fool RX statistics. This is definitely
  a hardware bug and we intend to provide a workaround in v0.21
* nForce3 systems are programmed to an incredibly high interrupt
  rate. We still need to find out what value to write to the
  timer register and we intend to fix this in v0.21
* "eth0: received irq with unknown events 0x<something>.
  Please report" might show up in your logs. That means we
  didn't encounter such an event during development and can
  only guess about its meaning.
  Please tell us what you were doing when the message appeared,
  how often it appeared and if it affects behaviour of your
  machine negatively.

Please test.


Regards,
Carl-Daniel
