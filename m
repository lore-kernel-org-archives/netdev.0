From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 8325] New: -j REDIRECT --to-ports 1000-1009,
 always first choosen
Date: Mon, 16 Apr 2007 07:12:33 +0200
Message-ID: <462305C1.9030007@trash.net>
References: <200704132053.l3DKrC9X000466@fire-2.osdl.org> <20070413144702.8ebf1cfe.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
To: wijata@nec-labs.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64131 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753675AbXDPFOf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2007 01:14:35 -0400
In-Reply-To: <20070413144702.8ebf1cfe.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> On Fri, 13 Apr 2007 13:53:12 -0700
> bugme-daemon@bugzilla.kernel.org wrote:
> 
> 
>>http://bugzilla.kernel.org/show_bug.cgi?id=8325
>>
>>           Summary: -j REDIRECT --to-ports 1000-1009, always first choosen
>>    Kernel Version: 2.6.19-1.2911.fc6PAE 2.6.19-gentoo-r4
>>            Status: NEW
>>          Severity: normal
>>             Owner: networking_netfilter-iptables@kernel-bugs.osdl.org
>>         Submitter: wijata@nec-labs.com
>>
>>
>>Most recent kernel where this bug did *NOT* occur:
>>Distribution: FC6, gentoo
>>Hardware Environment:
>>Software Environment:
>>Problem Description:
>>
>>Steps to reproduce:
>>Try redirecting to range of ports with iptables, kernel(?) will always redirect 
>>to first port from given range.


It will use a different port if there is a clash (a connection with the
same identity already exists). I'm guessing you're expecting that it
will use the ports in order. We might be able to change that, but I
don't really see a case where it would make sense. Please describe what
you're trying to do.

