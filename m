From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: FW:  ccid2/ccid3 oopses
Date: Wed, 9 Jan 2008 14:17:19 +0000
Message-ID: <20080109141719.GA10175@gerrit.erg.abdn.ac.uk>
References: <93680347@web.de> <20080109122827.GC4461@gerrit.erg.abdn.ac.uk> <20080109140211.GA9857@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Arnaldo Carvalho de Melo <acme@redhat.com>, devzero@web.de,
	dccp@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:63127 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751149AbYAIOSL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jan 2008 09:18:11 -0500
Content-Disposition: inline
In-Reply-To: <20080109140211.GA9857@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| > >> the easiest way to reproduce is:
| > >> 
| > >> while true;do modprobe dccp_ccid2/3;modprobe -r dccp_ccid2/3;done
| > >> after short time, the kernel oopses (messages below)
| > >> 
<snip>
| 
| Gerrit, the control socket isn't attached to any CCID module, so the
| CCID modules should be safe to remove, and IIRC they were safe to
| unload.
| 
Ah, right. I have misread the email. And can confirm the above: running
the for-loop at the top of the message (60 seconds uninterrupted for
CCID2,3 each) brought no oopses.
So maybe the cause triggering this oops is somewhere else.
