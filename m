From: Mohammad Alsaleh <msal@tormail.org>
Subject: Re: ping -f is broken in iputils 20121011
Date: Wed, 31 Oct 2012 12:11:11 +0300
Message-ID: <1TTUJN-000MzR-Tp@internal.tormail.org>
References: <20121030205249.GA2817@mail>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outgoing.tormail.org ([82.221.96.22]:45256 "EHLO
	outgoing.tormail.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933199Ab2JaJMr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2012 05:12:47 -0400
Received: from localhost ([127.0.0.1] helo=internal.tormail.org)
	by outgoing.tormail.org with esmtp (Exim 4.72)
	(envelope-from <msal@tormail.org>)
	id 1TTULp-0008N6-3k
	for netdev@vger.kernel.org; Wed, 31 Oct 2012 12:12:43 +0300
Received: from msal by internal.tormail.org with local (Exim 4.63)
	(envelope-from <msal@tormail.org>)
	id 1TTUJN-000MzR-Tp
	for netdev@vger.kernel.org; Wed, 31 Oct 2012 09:10:13 +0000
Content-Disposition: inline
In-Reply-To: <20121030205249.GA2817@mail>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 30, 2012 at 11:52:49PM +0300, Mohammad Alsaleh wrote:
> As explained in this bug report(1). ping -f seems to be broken in
> iputils 20121011.
> 
> (1) https://bugs.archlinux.org/task/32306

Bisected to commit 8feb586c4c6df32badb159947ed233898891aecd
