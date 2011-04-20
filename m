From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH V3 5/8] Enable cxgb3 to support zerocopy
Date: Wed, 20 Apr 2011 13:58:54 -0700
Message-ID: <1303333134.19336.70.camel@localhost.localdomain>
References: <1303328216.19336.18.camel@localhost.localdomain>
	 <1303330438.19336.57.camel@localhost.localdomain>
	 <4DAF479D.7090309@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, mst@redhat.com,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Dimitris Michailidis <dm@chelsio.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4DAF479D.7090309@chelsio.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-04-20 at 13:52 -0700, Dimitris Michailidis wrote:
> The features handling has been reworked in net-next and patches like
> this 
> won't apply as the code you're patching has changed.  Also core code
> now 
> does a lot of the related work and you'll need to tell it what to do
> with 
> any new flags.
Ok, will do.

> What properties does a device or driver need to meet to set this flag?
> It 
> seems to be set a bit too unconditionally.  For example, does it work
> if one 
> disables scatter/gather? 

This flag can be ON when HIGHDMA and scatter/gather support. I will
modify the patch to make it conditionally.

thanks
Shirley

