From: David Miller <davem@davemloft.net>
Subject: Re: [RFC net-next 1/2] if_link : add support for VF privileges
Date: Tue, 21 Feb 2012 17:04:41 -0500 (EST)
Message-ID: <20120221.170441.1552294498786802979.davem@davemloft.net>
References: <20120214192627.GA14163@akhaparde-VBox>
	<1329261897.2443.60.camel@bwh-desktop>
	<49395329523DD64492581B505F80C86D5BDCF681FD@EXMAIL.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, shemminger@linux-foundation.org,
	netdev@vger.kernel.org
To: Ajit.Khaparde@Emulex.Com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:32887 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752693Ab2BUWEr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 17:04:47 -0500
In-Reply-To: <49395329523DD64492581B505F80C86D5BDCF681FD@EXMAIL.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <Ajit.Khaparde@Emulex.Com>
Date: Tue, 21 Feb 2012 14:02:27 -0800

>> -----Original Message-----
>> From: Ben Hutchings [mailto:bhutchings@solarflare.com]
>> Sent: Tuesday, February 14, 2012 5:25 PM
>> To: Khaparde, Ajit
>> Cc: davem@davemloft.net; shemminger@linux-foundation.org;
>> netdev@vger.kernel.org
>> Subject: Re: [RFC net-next 1/2] if_link : add support for VF privileges
>> 
>> On Tue, 2012-02-14 at 13:26 -0600, Ajit Khaparde wrote:
>> > +enum {
>> > +	IFLA_VF_PRIVILEGE_DEFAULT = 1,	/* Default privileges */
>> 
>> What are the default privileges?  Should existing drivers report that
>> their VFs have this?
> Yes. Vendors can decide what privileges they want to grant for VFs by default.

That's terrible and a very bad interface for users.  It means every system
can have different defaults, from which we'll derive zero consistency.
