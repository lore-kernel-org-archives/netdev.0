From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Subject: [RFC] acx100 inclusion in mainline; generic 802.11 stack
Date: Tue, 31 Aug 2004 21:11:02 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200408312111.02438.vda@port.imtp.ilyichevsk.odessa.ua>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Cc: acx100-devel@lists.sourceforge.net, netdev@oss.sgi.com,
        prism54-devel@prism54.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Jean Tourrilhes <jt@bougret.hpl.hp.com>,
        Jouni Malinen <jkmaline@cc.hut.fi>, jgarzik@pobox.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi all,

It looks like acx100 approaches state when we can consider it's inclusion
into mainline kernel.

Some background information: acx100 and acx111 hardware is a bit like
Atheros and possibly prism54 "softmac": it handles mostly low-level
rx/tx stuff, leaving 802.11 stack implementation up to OS
(which is good. To have largish potentially buggy binary-only firmware
to cope with is a nightmare).

I think what acx100 devel is working on can be best described as
"yet another 802.11 stack implementation". This is not ok.

I think we definitely need generic 802.11 stack, with individual drivers
providing only needed callbacks, just like it is done for wired eth drivers.

I think 'senior' network guys are in position to decide upon which 
of currently available 802.11 stacks we should continue to work.
(Atheros has one, said to be derived from BSD, is there any others?)

Give us some guidance please...
--
vda
