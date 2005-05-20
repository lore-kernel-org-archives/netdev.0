From: jamal <hadi@cyberus.ca>
Subject: Re: 2.6.12-rc4-mm[12] - ULOG problem
Date: Fri, 20 May 2005 07:42:47 -0400
Message-ID: <1116589367.6308.36.camel@localhost.localdomain>
References: <20050518222729.007887b8.akpm@osdl.org>
	 <1116484313.21310.78.camel@uganda> <20050518234552.4aef6d02.akpm@osdl.org>
	 <20050519.114425.18307286.davem@davemloft.net>
	 <1116571178.21310.124.camel@uganda>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, akpm@osdl.org,
        herbert@gondor.apana.org.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: johnpol@2ka.mipt.ru
In-Reply-To: <1116571178.21310.124.camel@uganda>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-20-05 at 10:39 +0400, Evgeniy Polyakov wrote:

> I just want to note, that if you want message bus, you require
> at least oppsite direction, and thus input callback, and
> either several socket number for each user [kobject, audit, iscsi, 
> xfrm - all they implement what connector already does] or
> some header and thus parser in input callback, and thus
> some registration mechanism. 


But if you are given your own ID, there should no issues, correct?
i.e it will be no different than say rtnetlink. Users would still have
to subscribe to topics etc, but thats something you already handle.
IOW, Iam hoping you are not resorting to a single socket with some user
space mux to do filtering.

cheers,
jamal
