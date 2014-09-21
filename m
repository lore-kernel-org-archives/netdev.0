From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: Re: [PATCH net-next v2 2/2] enic: Add ethtool support to show
 classifier filters added by the driver
Date: Mon, 22 Sep 2014 03:17:29 +0530 (IST)
Message-ID: <alpine.LNX.2.03.1409220255370.26194@ws.cisco>
References: <1405943538-3086-1-git-send-email-_govind@gmx.com>  <1405943538-3086-3-git-send-email-_govind@gmx.com> <1409972482.7389.22.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Govindarajulu Varadarajan <_govind@gmx.com>, davem@davemloft.net,
	netdev@vger.kernel.org, ssujith@cisco.com, benve@cisco.com
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.200]:63187 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751313AbaIUVrz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Sep 2014 17:47:55 -0400
In-Reply-To: <1409972482.7389.22.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 6 Sep 2014, Ben Hutchings wrote:

> On Mon, 2014-07-21 at 17:22 +0530, Govindarajulu Varadarajan wrote:
>> This patch impliments ethtool_ops->get_rxnfc() to display the classifier
>> filter added by the driver.
> [...]
>
> ARFS and ethtool RXNFC are two different interfaces for setting filters
> and they shouldn't be confused with each other.
>
> In the sfc driver, I made the filters inserted through each interface
> invisible from the other.  The mlx4_en driver also appears to keep the
> two sets of filters separate.
>
> I can see that it is useful to be able to find out which filters have
> been inserted through ARFS, but it should be possible to distinguish
> them from those inserted through RXNFC.  Please don't include those
> filters when ETHTOOL_GRXCLSRLCNT or ETHTOOL_GRXCLSRLALL are used.
>
> Either add new command numbers for getting ARFS filters (the same
> structures will do), or define some kind of extension flag for this
> purpose.
>

Will work on adding new ethtool cmd with same infrastructure as RXNFC for
displaying filters added by ARFS, removing existing get_rxnfc for enic and
use new ethtool cmd.

Thanks for your feedback.
