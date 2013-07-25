From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3] tuntap: allow changing ethtool speed (v2)
Date: Wed, 24 Jul 2013 17:29:26 -0700 (PDT)
Message-ID: <20130724.172926.1881479319860230451.davem@davemloft.net>
References: <20130724161156.4a8cf02b@nehalam.linuxnetplumber.net>
	<1374709250.1732.40.camel@bwh-desktop.uk.level5networks.com>
	<20130724171750.112cf0df@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, h.grohne@cygnusnetworks.de,
	netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36870 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752775Ab3GYA33 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jul 2013 20:29:29 -0400
In-Reply-To: <20130724171750.112cf0df@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Wed, 24 Jul 2013 17:17:50 -0700

> On Thu, 25 Jul 2013 00:40:50 +0100
> Ben Hutchings <bhutchings@solarflare.com> wrote:
> 
>> On Wed, 2013-07-24 at 16:11 -0700, Stephen Hemminger wrote:
>> > The data reported by the ethtool interface for tun/tap devices is
>> > artificial. The default speed is 10Mbit. Virtual interfaces are often
>> > faster than this nowadays, so the observed bandwidth may exceed the
>> > available bandwidth. This patch allows an administrator to change the
>> > available bandwidth as reported by ethtool.
>> > 
>> > Signed-off-by: Helmut Grohne <h.grohne@cygnusnetworks.de>
>> > Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
>> > 
>> > ---
>> > v2 - allow setting duplex as well, fix patch formatting
>> 
>> It's logically full duplex so this doesn't make sense to me.
>> 
>> >      ignore other settings in set
>> [...]
>> 
>> No, please never do that in ethtool_ops::set_settings.  Setting
>> unsupported values is an error.
> 
> Almost every hardware driver out there allows mucking with settings
> that it doesn't care about (like transceiver and port). Why be picky now?

Those are bugs to be fixed, rather than things to emulate.

And honestly this is an unrelated thing to mention given the point Ben
is trying to make.
