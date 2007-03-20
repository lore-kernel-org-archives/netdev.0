From: Andreas Kleen <ak@suse.de>
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap paravirt ops	callsites to make them patchable
Date: Tue, 20 Mar 2007 12:33:10 +0100 (CET)
Message-ID: <331404.1174390390026.SLOX.WebMail.wwwrun@imap-dhs.suse.de>
References: <20070316.023331.59468179.davem@davemloft.net> <45FB005D.9060809@goop.org> <1174127638.8897.75.camel@localhost.localdomain> <20070318.003309.71088169.davem@davemloft.net> <20070318120814.GA45869@muc.de> <1174272469.11680.23.camel@localhost.localdomain> <m1648xxf93.fsf@ebiederm.dsl.xmission.com> <Pine.LNX.4.64.0703191134190.6730@woody.linux-foundation.org> <1174348905.11680.54.camel@localhost.localdomain> <45FF4043.4000805@vmware.com> <45FF770C.7050301@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Zachary Amsden <zach@vmware.com>, xen-devel@lists.xensource.com,
	akpm@linux-foundation.org, virtualization@lists.osdl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chrisw@sous-sol.org, Andi Kleen <ak@muc.de>,
	"Eric W. Biederman" <ebiederm@xmission.com>, anthony@codemonkey.ws,
	mingo@elte.hu, Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:42060 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753573AbXCTLdz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Mar 2007 07:33:55 -0400
In-Reply-To: <45FF770C.7050301@goop.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Di 20.03.2007 06:54 schrieb Jeremy Fitzhardinge <jeremy@goop.org>:

> Zachary Amsden wrote:
> > For VMI, the default clobber was "cc", and you need a way to allow
> > at
> > least that, because saving and restoring flags is too expensive on
> > x86.
>
> According to lore (Andi, I think), asm() always clobbers cc.

asm with input and/or output. I'm not sure about asms without that.

-Andi


