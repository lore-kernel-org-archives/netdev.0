From: Mark Smith <ipng@69706e6720323030352d30312d31340a.nosense.org>
Subject: Bug in order of multiple IPv6 addresses per interface? Newest added
 one is preferred in difference to IPv4
Date: Mon, 21 Aug 2006 18:56:10 +0930
Message-ID: <20060821185610.07dce833.ipng@69706e6720323030352d30312d31340a.nosense.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ihug-mail.icp-qv1-irony3.iinet.net.au ([203.59.1.197]:3217 "EHLO
	mail-ihug.icp-qv1-irony3.iinet.net.au") by vger.kernel.org with ESMTP
	id S1751046AbWHUJ0K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Aug 2006 05:26:10 -0400
To: pb@bieringer.de
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Sorry not to preserve the list/thread ID, I read the list via nntp/gmane, so please also CC' me directly for replies.

># ip -6 addr show dev eth0  |grep -w inet6 |grep -w global
    inet6 2001:db8:0:1::253/64 scope global   <- #2 !!!!
    inet6 2001:db8:0:1::11/64 scope global    <- #1

>So the last added on is now the first in list. Also, it gets no
>"secondary" flag and "ip" doesn't even support this flag.

>And the worse thing is that the first one in list (= last added one) is
>now used as default for outgoing connections. Can be easily tested using
>"ping6".


>Is this a bug (I hope so) or a (undocumented?) feature?

Could it be because the new address as a newer and therefore longer
preferred and valid lifetimes, and therefore becomes a more preferred
IPv6 source address to use for new connections ? 

Regards,
Mark.
