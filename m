From: Scott Feldman <scofeldm@cisco.com>
Subject: Re: [net-next PATCH 5/6] enic: feature add: add ethtool -c/C support
Date: Wed, 23 Dec 2009 11:15:00 -0800
Message-ID: <C757AC34.1B4BB%scofeldm@cisco.com>
References: <1261591999.2782.41.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:63084 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753576AbZLWTPH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 14:15:07 -0500
In-Reply-To: <1261591999.2782.41.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/23/09 10:13 AM, "Ben Hutchings" <bhutchings@solarflare.com> wrote:

> On Mon, 2009-12-21 at 18:21 -0800, Scott Feldman wrote:
>> From: Scott Feldman <scofeldm@cisco.com>
>> 
>> Only rx_usec and tx_usec options for ethtool -C are settable as those
>> are the only settings that make sense to HW.  Adds driver reporting of
>> intr coalescing timer value in usec units rather than HW units.
> [...]
>> diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
>> index 019b148..81cc68d 100644
>> --- a/drivers/net/enic/enic_main.c
>> +++ b/drivers/net/enic/enic_main.c
>> @@ -261,7 +261,63 @@ static void enic_set_msglevel(struct net_device *netdev,
>> u32 value)
>> enic->msg_enable = value;
>>  }
>>  
>> -static const struct ethtool_ops enic_ethtool_ops = {
> [...]
>> +static struct ethtool_ops enic_ethtool_ops = {
> [...]
> 
> I don't see any reason to remove the const here.  Is that an accidental
> change?

That was a mistake.  Sigh.  Let me resend patch set without that change...

[I'll wait a while in case there are any more review comments]

-scott

