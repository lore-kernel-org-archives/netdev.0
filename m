From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tproxy: copy transparent flag when creating a time wait
Date: Tue, 18 Oct 2011 16:48:03 -0400 (EDT)
Message-ID: <20111018.164803.588126048510438075.davem@davemloft.net>
References: <1318969055.2959.7.camel@nessa.odu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: hidden@balabit.hu
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1318969055.2959.7.camel@nessa.odu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: KOVACS Krisztian <hidden@balabit.hu>
Date: Tue, 18 Oct 2011 22:17:35 +0200

> The transparent socket option setting was not copied to the time wait
> socket when an inet socket was being replaced by a time wait socket. This
> broke the --transparent option of the socket match and may have caused
> that FIN packets belonging to sockets in FIN_WAIT2 or TIME_WAIT state
> were being dropped by the packet filter.
> 
> Signed-off-by: KOVACS Krisztian <hidden@balabit.hu>

I can't believe such a fundamental bug went unspotted for so long :-)

I'll apply this, thanks.
