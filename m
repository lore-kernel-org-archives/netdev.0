From: Michael Neuling <mikey@neuling.org>
Subject: Re: [PATCH 3/6] ehea: queue management
Date: Fri, 11 Aug 2006 10:46:01 +1000
Message-ID: <20060811004602.23EB467B64@ozlabs.org>
References: <44D99F38.8010306@de.ibm.com> <20060811000540.200CE67B6B@ozlabs.org> <20060811003204.GA6935@martell.zuzino.mipt.ru>
Reply-To: Michael Neuling <mikey@neuling.org>
Cc: Jan-Bernd Themann <ossthema@de.ibm.com>, netdev@vger.kernel.org,
	Thomas Klein <tklein@de.ibm.com>, linuxppc-dev@ozlabs.org,
	Christoph Raisch <raisch@de.ibm.com>,
	linux-kernel@vger.kernel.org, Marcus Eder <meder@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:8836 "EHLO ozlabs.org")
	by vger.kernel.org with ESMTP id S932396AbWHKAqD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2006 20:46:03 -0400
To: Alexey Dobriyan <adobriyan@gmail.com>
In-reply-to: <20060811003204.GA6935@martell.zuzino.mipt.ru> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > > +static inline u32 map_swqe_size(u8 swqe_enc_size)
> > > +{
> > > +	return 128 << swqe_enc_size;
> > > +}		      ^
> > > +		      |
> > > +static inline u32|map_rwqe_size(u8 rwqe_enc_size)
> > > +{		      |
> > > +	return 128 << rwqe_enc_size;
> 		      ^
> > > +}		      |
> >		      |
> > Snap!  These are ide|tical...
> 		      |
> No, they aren't. -----+

Functionally identical.

Mikey
