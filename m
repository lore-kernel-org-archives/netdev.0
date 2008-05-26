From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [bug] stuck localhost TCP connections, v2.6.26-rc3+
Date: Mon, 26 May 2008 09:24:07 -0700
Message-ID: <20080526092407.76df09d7@infradead.org>
References: <20080526115628.GA31316@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Andrew Morton <akpm@linux-foundation.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:40646 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751414AbYEZRHn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 May 2008 13:07:43 -0400
In-Reply-To: <20080526115628.GA31316@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 26 May 2008 13:56:28 +0200
Ingo Molnar <mingo@elte.hu> wrote:

> 
> in an overnight -tip testruns that is based on recent -git i got two 
> stuck TCP connections:
> 
> Active Internet connections (w/o servers)
> Proto Recv-Q Send-Q Local Address               Foreign
> Address             State tcp        0 174592
> 10.0.1.14:58015             10.0.1.14:3632              ESTABLISHED
> tcp    72134      0 10.0.1.14:3632
> 10.0.1.14:58015             ESTABLISHED 
> 
> on a previously reliable machine. That connection has been stuck for
> 9 hours so it does not time out, etc. - and the distcc run that goes
> over that connection is stuck as well.
> 

interestingly enough, I think I'm seeing something very similar to this
with the claws email client; as of 2.6.26-rc3 (sorry, didn't run
earlier ones because they broke my wireless) claws gets "stuck" once in
a while, really stuck, when talking to the imap server.....
It seems to happen a little less frequently when running under strace,
but it still happens, so that could just be a timing thing.

