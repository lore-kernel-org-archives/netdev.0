From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] sb1250-mac.c: De-typedef, de-volatile, de-etc...
Date: Thu, 20 Sep 2007 13:01:45 -0400
Message-ID: <46F2A779.2040904@pobox.com>
References: <Pine.LNX.4.64N.0709101310030.25038@blysk.ds.pg.gda.pl> <46E8B56E.7060705@pobox.com> <Pine.LNX.4.64N.0709131506040.31069@blysk.ds.pg.gda.pl> <20070913151452.GB29665@linux-mips.org> <46E95C7F.1050302@pobox.com> <Pine.LNX.4.64N.0709141135290.1926@blysk.ds.pg.gda.pl> <46F1F2CE.7020300@pobox.com> <Pine.LNX.4.64N.0709201354320.30788@blysk.ds.pg.gda.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ralf Baechle <ralf@linux-mips.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, linux-mips@linux-mips.org,
	linux-kernel@vger.kernel.org
To: "Maciej W. Rozycki" <macro@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60101 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751134AbXITRBv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Sep 2007 13:01:51 -0400
In-Reply-To: <Pine.LNX.4.64N.0709201354320.30788@blysk.ds.pg.gda.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Maciej W. Rozycki wrote:
> On Thu, 20 Sep 2007, Jeff Garzik wrote:
> 
>>> You may be pleased (or less so) to hear that the version of sb1250-mac.c in
>>> your tree does not even build (because of
>>> 42d53d6be113f974d8152979c88e1061b953bd12) and the patch below does not
>>> address it.  I ran out of time in the evening, but I will send you a fix
>>> shortly.  To be honest I think even with bulk changes it may be worth
>>> checking whether they do not break stuff. ;-)
>> hrm.  I cannot get this to apply on top of linux-2.6.git,
>> netdev-2.6.git#upstream (prior to net-2.6.24 rebase) or
>> netdev-2.6.git#upstream (after net-2.6.24 rebase)
> 
>  It applies on top of current -mm.  It seems to apply to a copy of 
> netdev-2.6.git#upstream that I have got, but I am probably missing 
> something...  If I try to clone your repository again I get:
> 
> $ git clone git://git.kernel.org/pub/scm/linux/kernel/git/jgarzik/linux-netdev-2.6.git linux
> Initialized empty Git repository in /home/macro/GIT-other/linux-netdev/linux/.git/
> fatal: The remote end hung up unexpectedly
> fetch-pack from 'git://git.kernel.org/pub/scm/linux/kernel/git/jgarzik/linux-netdev-2.6.git' failed.

Remove the "linux-" prefix.

	Jeff



