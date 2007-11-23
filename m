From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [Bugme-new] [Bug 9440] New: Problem in joinning a socket to ipv6 multicast address in specific scenario
Date: Fri, 23 Nov 2007 13:59:24 +0300
Message-ID: <20071123105924.GB22062@2ka.mipt.ru>
References: <bug-9440-10286@http.bugzilla.kernel.org/> <20071122172342.721ee232.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	aviad.yehezkel5@gmail.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:33568 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753899AbXKWK7p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Nov 2007 05:59:45 -0500
Content-Disposition: inline
In-Reply-To: <20071122172342.721ee232.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 22, 2007 at 05:23:42PM -0800, Andrew Morton (akpm@linux-foundation.org) wrote:
> > 3. Now i am running a program i wrote in c that opens a dgram socket
> > (sock_fd[i] = socket(test_data->protocol, SOCK_DGRAM, 0);)  and join it to
> > multicast ipv6 address. 
> > if i am running this program after steps 1+2 i get the following error:
> > "Resource temporarily unavailable" when trying to join the socket to the
> > multicast ipv6 address by the
> > system call : 

Could you provide a test application?
Given it is small and can be ran without external dependencies, it will
be fixed way much faster.

Thanks.

-- 
	Evgeniy Polyakov
