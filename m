From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 1/2] mpls: packet stats
Date: Mon, 8 Feb 2016 11:51:34 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CCDAD79@AcuExch.aculab.com>
References: <1454700472-13543-1-git-send-email-rshearma@brocade.com>
 <1454700472-13543-2-git-send-email-rshearma@brocade.com>
 <20160206105843.GA27535@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: 'Francois Romieu' <romieu@fr.zoreil.com>,
	Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.188]:50793 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750818AbcBHLyP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2016 06:54:15 -0500
In-Reply-To: <20160206105843.GA27535@electric-eye.fr.zoreil.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu
> Sent: 06 February 2016 10:59
> > +void mpls_stats_inc_outucastpkts(struct net_device *dev,
> > +				 const struct sk_buff *skb)
> > +{
> > +	struct mpls_dev *mdev;
> > +	struct inet6_dev *in6dev;
> 
> Nit: the scope can be reduced for both variables.

And hiding the definitions of variables in the middle of
functions just makes them harder to find.	

	David
