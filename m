From: David Miller <davem@davemloft.net>
Subject: Re: [e1000]: flow control on by default - good idea really?
Date: Thu, 06 Jul 2006 23:59:09 -0700 (PDT)
Message-ID: <20060706.235909.78729229.davem@davemloft.net>
References: <44AC05A8.9030503@intel.com>
	<Pine.LNX.4.64.0607052241230.12611@bizon.gios.gov.pl>
	<1152191018.5103.48.camel@jzny2>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: olel@ans.pl, jgarzik@pobox.com, greearb@candelatech.com,
	john.ronciak@intel.com, Robert.Olsson@data.slu.se,
	jesse.brandeburg@intel.com, netdev@vger.kernel.org,
	auke-jan.h.kok@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:63926
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751226AbWGGG6y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jul 2006 02:58:54 -0400
To: hadi@cyberus.ca
In-Reply-To: <1152191018.5103.48.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Thu, 06 Jul 2006 09:03:38 -0400

> On Wed, 2006-05-07 at 22:45 +0200, Krzysztof Oledzki wrote:
> > 
> > On Wed, 5 Jul 2006, Auke Kok wrote:
> > 
> > > David Miller wrote:
> > >> From: jamal <hadi@cyberus.ca>
> > >> Date: Tue, 04 Jul 2006 15:20:39 -0400
> > >> 
> > >>> BTW, As an addendum this default behavior changed around 2.6.16 it
> > >>> seems.
> > >> 
> > >> Flow control has been on by default in the tg3 driver since the
> > >> beginning, 
> 
> Are you sure about this Dave?;-> because I do have a tg3 on my laptop.
> 
> hadi@jzny2:~/Desktop/maemo$ sudo ethtool -a eth0
> Pause parameters for eth0:
> Autonegotiate:  on
> RX:             off
> TX:             off

It's autonegotiated, check you kernel message logs when the link
came up, you'll see this:

tg3: eth0: Flow control is on for TX and on for RX.

Take care.
