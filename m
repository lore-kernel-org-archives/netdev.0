From: Joe Perches <joe@perches.com>
Subject: Re: ping [PATCH v3] WAN: Adding support for Lantiq PEF2256 E1
 chipset (FALC56)
Date: Sun, 19 Jan 2014 22:22:22 -0800
Message-ID: <1390198942.2472.5.camel@joe-AO722>
References: <20140119180732.A1D99432AF@localhost.localdomain>
	 <1390160095.2290.9.camel@joe-AO722> <52DC72CA.3090403@landley.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Christophe Leroy <christophe.leroy@c-s.fr>,
	Rob Herring <rob.herring@calxeda.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Stephen Warren <swarren@wwwdotorg.org>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Grant Likely <grant.likely@linaro.org>,
	Krzysztof Halasa <khc@pm.waw.pl>, devicetree@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, marc.balemboy@c-s.fr
To: Rob Landley <rob@landley.net>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <52DC72CA.3090403@landley.net>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2014-01-19 at 18:50 -0600, Rob Landley wrote:
> On 01/19/14 13:34, Joe Perches wrote:
> > On Sun, 2014-01-19 at 19:07 +0100, Christophe Leroy wrote:
> >> Pinging this watch as we got no feedback since 22 Nov, although we have taken
> >> into account reviews from v1 and v2.
> >>
> >> The patch adds WAN support for Lantiq FALC56 - PEF2256 E1 Chipset.
> ...
> >> +static ssize_t fs_attr_Tx_TS_store(struct device *dev,
> >> +			struct device_attribute *attr,  const char *buf,
> >> +			size_t count)
> >> +{
> >> +	struct net_device *ndev = dev_get_drvdata(dev);
> >> +	struct pef2256_dev_priv *priv = dev_to_hdlc(ndev)->priv;
> >> +	unsigned long value;
> >> +	int ret = kstrtoul(buf, 16, (long int *)&value);
> >
> > unportable cast

> How is that not portable? It's long == pointer on Linux, which supports 
> LP64 on all targets. (As do BSD, MacOSX, android, and iOS.)

Sorry, I read it wrong.
long int is the same size as long and is fine.
I thought it was just int.

Still, declaring
	unsigned long foo;
and using
	(long int *)&foo;

is mixing implicit and explicit styles and perhaps
should be avoided.

> Do you mean it's not portable to Windows?
>    http://blogs.msdn.com/oldnewthing/archive/2005/01/31/363790.aspx

I hardly remember that stuff anymore.

cheers, Joe

