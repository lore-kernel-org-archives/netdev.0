From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 0/4] switchdev: push bridge attributes down
Date: Fri, 25 Sep 2015 03:53:05 +0200
Message-ID: <20150925015305.GA25275@lunn.ch>
References: <1443128370-27353-1-git-send-email-sfeldma@gmail.com>
 <5604A208.3030902@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sfeldma@gmail.com, netdev@vger.kernel.org, jiri@resnulli.us,
	siva.mannem.lnx@gmail.com, pjonnala@broadcom.com,
	stephen@networkplumber.org, roopa@cumulusnetworks.com,
	vivien.didelot@savoirfairelinux.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:53417 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753190AbbIYCBS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Sep 2015 22:01:18 -0400
Content-Disposition: inline
In-Reply-To: <5604A208.3030902@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> So, without a better device to hold that kind of information (in the
> future it could be a global, switch-specific device holding that
> information), I agree with your decision to take the bridge device to
> hold that attribute, it still feels a bit uncomfortable to have
> switchdev_attr_port() take a bridge device parameter, but whatever, here
> is a scenario I am wondering how we would want to proceed with:
> 
> - suppose we have a switch which is only able to control ageing
> globally, not per port or any other kind of logical domain

Marvell switches only have global ageing settings, and it has to be a
multiple of 15 seconds, from 0 to 3825 seconds.

	 Andrew
