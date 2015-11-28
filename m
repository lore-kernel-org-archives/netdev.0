From: Sasha Levin <sasha.levin@oracle.com>
Subject: Re: gigaset: freeing an active object
Date: Fri, 27 Nov 2015 20:27:40 -0500
Message-ID: <5659030C.1070009@oracle.com>
References: <56587467.8050102@oracle.com>
 <1448647077.6523.33.camel@tiscali.nl> <56589DD9.2060508@oracle.com>
 <1448670517.6523.67.camel@tiscali.nl> <56590159.4080404@hurleysoftware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, davem@davemloft.net, tilman@imap.cc,
	gigaset307x-common@lists.sourceforge.net,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>
To: Peter Hurley <peter@hurleysoftware.com>,
	Paul Bolle <pebolle@tiscali.nl>,
	Dmitry Vyukov <dvyukov@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:39491 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751606AbbK1B17 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2015 20:27:59 -0500
In-Reply-To: <56590159.4080404@hurleysoftware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/27/2015 08:20 PM, Peter Hurley wrote:
> It would really help if you included the syzkaller-generated applet with
> the bug reports; state previously established by the applet can be
> crucial in understanding why the call stack looks the way it does.
> 
> Also, every generated applet that triggers a report should become
> a future regression test; I'm collecting the ones pertinent to tty/serial/
> ldisc (so that includes this one; if you could send me the x25 one too
> would be great).

I went in to look for the 'crashers' that I thought are generated when
syzkaller manages to crash a kernel, but none appear for me.

Dmitry, is there magic required to generate those?


Thanks,
Sasha
