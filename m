From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: ethtool patch to support bypass / fail-to-wire function
Date: Wed, 11 Jun 2014 09:17:57 -0700
Message-ID: <20140611091757.78e1002d@nehalam.linuxnetplumber.net>
References: <3BFAEADE799AF145974162DF00E013AF018F794DE5@exchange2010.silicom.local>
	<1402322812.23860.76.camel@deadeye.wl.decadent.org.uk>
	<3BFAEADE799AF145974162DF00E013AF018F798C22@exchange2010.silicom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Elad Blatt <eladb@silicom.co.il>
To: David Hendel <david@silicom.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:47961 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752409AbaFKQSA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 12:18:00 -0400
Received: by mail-pa0-f47.google.com with SMTP id fa1so2050121pad.6
        for <netdev@vger.kernel.org>; Wed, 11 Jun 2014 09:18:00 -0700 (PDT)
In-Reply-To: <3BFAEADE799AF145974162DF00E013AF018F798C22@exchange2010.silicom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver using this is not upstream. You need to get that driver reviewed
and incorporated in upstream kernel before the changes to ethtool will be
considered.

I expect that the driver will not be accepted as is, and therefore you will
have to make changes (including API changes), that render this ethtool API
moot.
