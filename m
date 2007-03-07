From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH]: Revert accept queue backlog change.
Date: Wed, 7 Mar 2007 09:19:07 +0100
Message-ID: <20070307081907.GA2268@ff.dom.local>
References: <20070306.111900.41634576.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: weid@np.css.fujitsu.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:35752 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S965095AbXCGIPI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Mar 2007 03:15:08 -0500
Content-Disposition: inline
In-Reply-To: <20070306.111900.41634576.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06-03-2007 20:19, David Miller wrote:
> Wei, I have to revert your change, it is incorrect as pointed
> out by other people here on netdev.
> 
> BSD sockets basically define the 'backlog' parameter to listen()
> to mean "allow backlog + 1" connections to be queued to the socket.
> This allows a backlog parameter of "0" to allow 1 connection, and
> there are real applications which do this.

Adding this comment somewhere shouldn't break anything,
I hope.

Regards,
Jarek P. 
