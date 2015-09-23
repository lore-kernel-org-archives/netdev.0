From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: Race with ip=dhcp bootparameter in ip_rcv_finish on am335x
Date: Wed, 23 Sep 2015 08:54:27 -0400
Message-ID: <20150923085427.4593c7dc@gandalf.local.home>
References: <20150923102953.GA8918@omega>
	<5602809D.2020500@cumulusnetworks.com>
	<20150923115757.GA23260@omega>
	<20150923122714.GA31569@omega>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	netdev@vger.kernel.org, trond.myklebust@primarydata.com
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0061.hostedemail.com ([216.40.44.61]:46725 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753922AbbIWMyb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 08:54:31 -0400
In-Reply-To: <20150923122714.GA31569@omega>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 23 Sep 2015 14:27:15 +0200
Alexander Aring <alex.aring@gmail.com> wrote:

\
> Finally I figured out that commit
> 4876cc779ff525b9c2376d8076edf47815e71f2c ("SUNRPC: Ensure we release the
> TCP socket once it has been closed") occur this races. After reverting
> this commit everything works fine.

Yay! Everybody sing! "Fix one bug and replace it by another..."

-- Steve
