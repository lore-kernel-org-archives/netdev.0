From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: Re: Loopback performance from kernel 2.6.12 to 2.6.37
Date: Wed, 10 Nov 2010 09:49:16 +0100
Message-ID: <1289378956.15004.22.camel@firesoul.comx.local>
References: <4CD9BE9C.30003@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Xose Vazquez Perez <xose.vazquez@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:41539 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753196Ab0KJItR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 03:49:17 -0500
In-Reply-To: <4CD9BE9C.30003@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-11-09 at 22:35 +0100, Xose Vazquez Perez wrote:
> Jesper Dangaard Brouer wrote:
> 
> > To fix this I added "-q 0" to netcat.  Thus my working commands are:
> > 
> >  netcat -l -p 9999 >/dev/null &
> >  time dd if=/dev/zero bs=1M count=10000 | netcat -q0 127.0.0.1 9999
> > 
> > Running this on my "big" 10G testlab system, Dual Xeon 5550 2.67GHz,
> > kernel version 2.6.32-5-amd64 (which I usually don't use)
> > The results are 7.487 sec:
> 
> netcat flavor ?

Debian package netcat-traditional
 netcat version [v1.10-38]

>From "aptitude show netcat-traditional":
 This is the "classic" netcat, written by *Hobbit*. It lacks many
features found in netcat-openbsd.

Didn't know there were that many flavors...

> http://nc110.sourceforge.net/
> http://nmap.org/ncat/
> http://www.dest-unreach.org/socat/
> http://cryptcat.sourceforge.net/
> http://netcat.sourceforge.net/
> http://www.openbsd.org/cgi-bin/cvsweb/src/usr.bin/nc/


-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network Kernel Developer
  Cand. Scient Datalog / MSc.CS
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer

