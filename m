From: margitsw@t-online.de (Margit Schubert-While)
Subject: Re: [PATCH/RFC] set_rates support for prism54
Date: Sun, 15 Aug 2004 21:10:05 +0200
Sender: prism54-devel-bounces@prism54.org
Message-ID: <5.1.0.14.2.20040815205413.02a70b28@pop.t-online.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Cc: mcgrof@studorgs.rutgers.edu, netdev@oss.sgi.com,
	jgarzik@pobox.com, vda@port.imtp.ilyichevsk.odessa.ua
Return-path: <prism54-devel-bounces@prism54.org>
To: prism54-devel@prism54.org
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org

Denis scribeth:
 > Ok. And then we will need to parse that data into format suitable for
 > prism54 in prism54 driver, and into format suitable for acx100/acx111
 > in acx100 driver, etc...

No, no. The format as it arrives at the driver should be fixed/defined.
Exactly as happens to private ioctls now.
Let's, for the sake of argument, say that we misuse the iw_freq structure.
(We can/should define a new structure)
iwpriv parses and sets up an iw_freq structure in the buffer that
it passes for -each- rate.
eg:
freq.i = rate
freq.m = modulation
freq.e = basic/extended

So, the driver gets a bunch of defined structures to act upon.

Margit
