From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 in 2.6.18 silently corrupting data, 2.6.22-rc3 link not detected at all
Date: Mon, 4 Jun 2007 23:09:59 +0200
Message-ID: <20070604210959.GA30864@electric-eye.fr.zoreil.com>
References: <76366b180705281110j472671a1h6ff5ed5fa711c45e@mail.gmail.com> <20070528195422.GA4927@electric-eye.fr.zoreil.com> <76366b180705281406j69d08bbeu77ff18991f161df8@mail.gmail.com> <20070528213425.GB4494@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, brad@langhorst.com
To: Andrew Paprocki <andrew@ishiboo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:52930 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752523AbXFDVMY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2007 17:12:24 -0400
Content-Disposition: inline
In-Reply-To: <20070528213425.GB4494@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu <romieu@fr.zoreil.com> :
[...]

Andrew, have you had any time to do some testing with an uniform 7200
bytes MTU through your LAN ?

You will find a backport of the r8169 driver for the 2.6.18 kernel at
http://www.fr.zoreil.com/people/francois/backport/r8169/20070604-00

Could you do a binary search of the patch which breaks the link detection ?
>From a different report that I have received, the current testing branch of
the 8169 driver would improve things for MTU beyond 1500 bytes: nailing down
your broken link regression would be a welcome improvement.

If you are confortable with git, you can do a git bisect after pulling
the branch 'r8169-backport-test-20070604' at:
git://electric-eye.fr.zoreil.com/home/romieu/linux/linux-2.6-out

(please do the initial clone from elsewhere if you use git, thanks)

-- 
Ueimor
