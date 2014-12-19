From: "Chickles, Derek" <Derek.Chickles@caviumnetworks.com>
Subject: RE: [PATCH net-next v3] Add support of Cavium Liquidio ethernet
 adapters
Date: Fri, 19 Dec 2014 17:54:58 +0000
Message-ID: <CO2PR07MB4901478A88B982967DBACA0FE6B0@CO2PR07MB490.namprd07.prod.outlook.com>
References: <feba8d6dd1904fc3936864ae332df6d8@CO2PR0701MB744.namprd07.prod.outlook.com>
	<1418959519-31681-1-git-send-email-rvatsavayi@caviumnetworks.com>
 <20141218225940.0697e3c5@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Burla, Satananda" <Satananda.Burla@caviumnetworks.com>,
	"Manlunas, Felix" <Felix.Manlunas@caviumnetworks.com>,
	"Vatsavayi, Raghu" <Raghu.Vatsavayi@caviumnetworks.com>
To: Stephen Hemminger <stephen@networkplumber.org>,
	"Vatsavayi, Raghu" <Raghu.Vatsavayi@caviumnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0084.outbound.protection.outlook.com ([207.46.100.84]:23968
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751142AbaLSSKf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2014 13:10:35 -0500
In-Reply-To: <20141218225940.0697e3c5@urahara>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > +static struct {
> > +	const char str[ETH_GSTRING_LEN];
> > +} ethtool_stats_keys[] = {
> > +	{
> > +		"jiffies"
> > +	}, {
> 
> Jiffies does not belong in ethtool stats. Looks like some developer debug
> option.

The intention here was to have a semi-accurate timestamp taken at the time
the statistics were gathered before handing it over to userspace. This is a
generic requirement though, so it probably belongs in ethtool_get_stats().
Otherwise, we can publish some per-second stats if that's preferable.
