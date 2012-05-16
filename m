From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH/RFC net-next 0/4] Delete token ring support.
Date: Wed, 16 May 2012 09:43:25 +0200
Message-ID: <20120516094325.001c0ee8@de.ibm.com>
References: <1337128544-18680-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	linux390@de.ibm.com, linux-s390@vger.kernel.org
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp12.uk.ibm.com ([195.75.94.108]:49052 "EHLO
	e06smtp12.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759539Ab2EPHnd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2012 03:43:33 -0400
Received: from /spool/local
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <schwidefsky@de.ibm.com>;
	Wed, 16 May 2012 08:43:31 +0100
In-Reply-To: <1337128544-18680-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 15 May 2012 20:35:40 -0400
Paul Gortmaker <paul.gortmaker@windriver.com> wrote:

> The one thing I wasn't aware of, until actually creating the commits
> to remove tokenring, was that s390 also had support for it.  I'm
> guessing that it is just as unused there as it is on x86, but the s390
> folks are CC'd for their input.

The LCS and OSA cards still have the token-ring mode. I can't remember
when we last tested this though, the last token-ring I have seen is like
10 years ago. I guess it is time to move on and get rid of it.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.
