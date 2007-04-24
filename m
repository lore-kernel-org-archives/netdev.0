From: petkan@nucleusys.com
Subject: Re: [PATCH] usb-net/pegasus: fix pegasus carrier detection
Date: Tue, 24 Apr 2007 20:48:01 +0300 (EEST)
Message-ID: <58298.85.91.128.158.1177436881.squirrel@nucleusys.com>
References: <1177424406.13684.5.camel@localhost.localdomain>
    <462E3508.1030703@garzik.org> <20070424170429.GA13668@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Jeff Garzik" <jeff@garzik.org>, "Dan Williams" <dcbw@redhat.com>,
	"Petko Manolov" <petkan@nucleusys.com>, netdev@vger.kernel.org
To: "Greg KH" <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from n152-u15.estnet.bg ([89.253.152.15]:4061 "EHLO
	zztop.nucleusys.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1422894AbXDXSSk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2007 14:18:40 -0400
In-Reply-To: <20070424170429.GA13668@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Tue, Apr 24, 2007 at 12:49:12PM -0400, Jeff Garzik wrote:
>>  Long term, Greg seemed OK with moving the net drivers from
>> drivers/usb/net
>>  to drivers/usb/net, in line with the current policy of placing net
>> drivers
>>  in drivers/net/*, bus agnostic.  After that move, sending to netdev and
>> me
>>  (as you did here) would be the preferred avenue.
>
> Speaking of which, do you want me to do this in the 2.6.22-rc1
> timeframe?  Usually big code moves like this are good to do right after
> rc1 comes out as the major churn is usually completed then.

Sorry to interfere, but could you guys wait until tomorrow before applying
the patch to your respective GIT trees?  I'd like to check if the code is
doing the right thing and avoid patch reversal.

cheers,
Petko

