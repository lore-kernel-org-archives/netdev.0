From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [ETHTOOL]: Add support for large eeproms
Date: Tue, 15 Apr 2008 19:23:30 -0700 (PDT)
Message-ID: <20080415.192330.29185957.davem@davemloft.net>
References: <20080414180338.GA18335@google.com>
	<20080415.003153.30044057.davem@davemloft.net>
	<cc96a5040804151007q6008355cl2cc85242b81f3918@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: msb@google.com, netdev@vger.kernel.org, jeff@garzik.org,
	joe@perches.com, nil@google.com, matthew@wil.cx
To: thockin@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42312
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753321AbYDPCX2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 22:23:28 -0400
In-Reply-To: <cc96a5040804151007q6008355cl2cc85242b81f3918@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Tim Hockin" <thockin@google.com>
Date: Tue, 15 Apr 2008 10:07:21 -0700

> On Tue, Apr 15, 2008 at 12:31 AM, David Miller <davem@davemloft.net> wrote:
> >
> >  This looks fine on the surface.
> >
> >  But I wonder what we can do if we have some EEPROM implementation
> >  that can only write the whole time at once, and thus will fail
> >  if you try to do it in pieces?  Do we have such a case?
> >
> >  If so this new code could cause regressions.
> 
> No device that I know of behaves that way.  It's certainly possible,
> but I've never seen any sort of PROM device that has such a
> requirement.

Fair enough, let's apply the patch and see if anything explode :)
