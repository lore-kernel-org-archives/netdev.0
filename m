From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2.6] dev.c: clear SIOCGIFHWADDR buffer if !dev->addr_len
Date: 01 Nov 2004 16:50:49 -0500
Message-ID: <1099345849.1073.1.camel@jzny.localdomain>
References: <20041030013700.GA21540@lists.us.dell.com>
	 <E1CNiOT-0008GU-00@gondolin.me.apana.org.au>
	 <20041030030936.GA25102@lists.us.dell.com>
	 <1099163419.1039.97.camel@jzny.localdomain>
	 <20041101044433.GA18772@lists.us.dell.com>
	 <20041101173434.GA12437@lists.us.dell.com>
	 <20041101202754.GA23149@gondor.apana.org.au>
	 <20041101203821.GA15086@lists.us.dell.com>
	 <20041101204131.GA23277@gondor.apana.org.au>
	 <20041101204533.GA17279@lists.us.dell.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Matt Domsch <Matt_Domsch@dell.com>
In-Reply-To: <20041101204533.GA17279@lists.us.dell.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

My onluy comment is on use of -EOVERFLOW which i have seen only
being used in the context of floating point computation
(same as -EUNDERFLOW). I dont know what the right thing to return would
be.

cheers,
jamal

On Mon, 2004-11-01 at 15:45, Matt Domsch wrote:
> On Tue, Nov 02, 2004 at 07:41:31AM +1100, Herbert Xu wrote:
> > You don't need the min anymore since you've checked that dev->addr_len
> > is not greater than sizeof ifr->ifr_hwaddr.sa_data.
> 
> Good catch.
> 
> Signed-off-by: Matt Domsch <Matt_Domsch@dell.com>
