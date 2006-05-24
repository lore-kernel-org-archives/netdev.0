From: Rick Jones <rick.jones2@hp.com>
Subject: Re: reminder, 2.6.18 window...
Date: Wed, 24 May 2006 13:25:18 -0700
Message-ID: <4474C12E.8050600@hp.com>
References: <20060523.182217.59656237.davem@davemloft.net>	<447412CA.50303@ipom.com> <4474A489.4080308@garzik.org>	<20060524185644.GF22881@ipom.com> <4474AE92.3030501@garzik.org>	<20060524191442.GG22881@ipom.com> <1148501433.5325.52.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Phil Dibowitz <phil@ipom.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:33942 "EHLO palrel10.hp.com")
	by vger.kernel.org with ESMTP id S932328AbWEXUZU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 May 2006 16:25:20 -0400
To: hadi@cyberus.ca
In-Reply-To: <1148501433.5325.52.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Can you provide some link to a vendor that allows resetting ethernet
> stats? I am almost certain, if they do they will have something or other
> which indicates that such a reset happened. It is also easier for cisco
> to have none standard feature "as of ios 15.16" which could support such
> behavior because they bundle everything including network management
> tools. We dont have that luxury. The BSDs may actually get away with it
> because they bundle user space apps as well. Perhaps some
> random Linux vendor as well..

The lanadmin (think ethtool) command of HP-UX has had a way to clear the 
statistics reported by lanadmin.  I do not know however, if that affects 
the stats in the actual SNMP interface MIBs as I've never had occasion 
to look.

I still suggest beforeafter to people because clearing the lanadmin 
stats requires root privs and because it may not be a kosher thing to do 
on a customer system.

HP-UX does not provide a way to clear the stats reported by netstat.

fwiw,

rick jones
