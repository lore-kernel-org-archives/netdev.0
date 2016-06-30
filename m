From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: Re: [PATCHv2 net-next 1/3] net: Add provision to specify pf number
 while assigning VF mac
Date: Thu, 30 Jun 2016 19:04:16 +0000
Message-ID: <CO2PR11MB0088BB6334851B5B51E5851497240@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1467300884-32340-1-git-send-email-hariprasad@chelsio.com>,<1467300884-32340-2-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev <netdev@vger.kernel.org>,
	"nirranjan@chelsio.com" <nirranjan@chelsio.com>,
	"leedom@chelsio.com" <leedom@chelsio.com>,
	"kumaras@chelsio.com" <kumaras@chelsio.com>
To: Hariprasad Shenai <hariprasad@chelsio.com>,
	David Miller <davem@davemloft.net>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0110.outbound.protection.outlook.com ([104.47.32.110]:58034
	"EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752149AbcGAANa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 20:13:30 -0400
In-Reply-To: <1467300884-32340-2-git-send-email-hariprasad@chelsio.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Chelsio T4/T5 cards have SR-IOV Capabilities on Physical Functions
> 0..3 and the administrative Driver(cxgb4) attaches to Physical Function 4.
> Each of the Physical Functions 0..3 can support up to 16 Virtual
> Functions. With the current Linux APIs, a 2-Port card would only be
> able to use the Virtual Functions on Physical Functions 0..1 and not
> allow the Virtual Functions on Physical Functions 2..3 to be used since
> there are no Ports 2..3 on a 2-Port card.
>
> Also the current ip commands takes netdev as one of the argument, and
> it assumes a 1-to-1 mapping of Network Ports, Physical Functions and the
> SR-IOV Virtual Functions of those Physical Functions. But it is not
> true in our case and won't work for us.
> 
> Added a new argument to specify the PF number associated with the VF, to
> fix this.

I don't get it - what's the exact definition of 'Physical Function'?
Are we talking PCI functions? Logical partitons? Something else?
