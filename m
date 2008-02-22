From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [NETFILTER]: Introduce nf_inet_address
Date: Fri, 22 Feb 2008 16:52:41 +0900
Message-ID: <1203666762.5771.35.camel@shinybook.infradead.org>
References: <200801291316.m0TDGivY024953@hera.kernel.org>
	 <1203428949.3223.25.camel@shinybook.infradead.org>
	 <47BAE13D.4060206@trash.net>
	 <1203431447.3223.33.camel@shinybook.infradead.org>
	 <47BAEB6C.1030609@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jan Engelhardt <jengelh@computergmbh.de>,
	"David S. Miller" <davem@davemloft.net>, varekova@redhat.com,
	twoerner@redhat.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:51905 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759672AbYBVHwq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2008 02:52:46 -0500
In-Reply-To: <47BAEB6C.1030609@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 2008-02-19 at 15:45 +0100, Patrick McHardy wrote:
> That would break iptables compilation, which already includes
> linux/in.h in some files. I guess the best fix for now is to
> include netinet/in.h in busybox and long-term clean this up
> properly.

It looks like iptables is fairly broken anyway:

make[1]: Entering directory `/home/dwmw2/working/extras/iptables/devel/iptables-1.4.0'
Unable to resolve dependency on linux/compiler.h. Try 'make clean'.
Extensions found:
make[1]: Leaving directory `/home/dwmw2/working/extras/iptables/devel/iptables-1.4.0'
error: Bad exit status from /var/tmp/rpm-tmp.32057 (%build)

-- 
dwmw2

