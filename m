From: Pete Clements <clem@clem.clem-digital.net>
Subject: Re: Second 3c509 missing (2.5.71 thru 2.6.0-t7)
Date: Fri, 10 Oct 2003 18:39:34 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310102239.SAA02061@clem.clem-digital.net>
References: <20031010124849.5ae48bd9.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: clem@clem.clem-digital.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20031010124849.5ae48bd9.shemminger@osdl.org> from Stephen Hemminger at "Oct 10, 2003 12:48:49 pm"
To: shemminger@osdl.org (Stephen Hemminger)
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Quoting Stephen Hemminger
  Tried, but does not fix, result is same. Thanks.
  > >
  > > I use 3c509 compiled in. Second card not detected. This has been the
  > > case with the stock kernel since 2.5.71.  Have been replacing the
  > > code for all kernels since .70.  Have not tried as modules.
  > 
  > Try this.
  > 
  > diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
  > --- a/drivers/net/Space.c	Fri Oct 10 10:03:42 2003
  > +++ b/drivers/net/Space.c	Fri Oct 10 10:03:42 2003
  > @@ -433,17 +433,15 @@
  >  	
  >  #ifdef CONFIG_SBNI
  >  	for (num = 0; num < 8; ++num)
  > -		if (sbni_probe(num))
  > -			break;
  > +		sbni_probe(num);
  >  #endif
  >  #ifdef CONFIG_TR
  >  	for (num = 0; num < 8; ++num)
  > -		if (trif_probe(num))
  > -			break;
  > +		trif_probe(num);
  >  #endif
  >  	for (num = 0; num < 8; ++num)
  > -		if (ethif_probe(num))
  > -			break;
  > +		ethif_probe(num);
  > +
  >  #ifdef CONFIG_COPS
  >  	cops_probe(0);
  >  	cops_probe(1);
  > 

-- 
Pete Clements 
