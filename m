From: <Ajit.Khaparde@Emulex.Com>
Subject: RE: [RFC] ethtool: Display reg dump length via get driver info.
Date: Fri, 18 Mar 2011 14:52:16 -0700
Message-ID: <49395329523DD64492581B505F80C86D5A5BCD38EA@EXMAIL.ad.emulex.com>
References: <ae232d9a-90c7-47ae-856d-bc5a2b3a8037@exht1.ad.emulex.com>,<1300483939.2589.46.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:16796 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932590Ab1CRVwh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2011 17:52:37 -0400
In-Reply-To: <1300483939.2589.46.camel@bwh-desktop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

______________________________________
From: Ben Hutchings [bhutchings@solarflare.com]
Sent: Friday, March 18, 2011 4:32 PM
To: Khaparde, Ajit
Cc: netdev@vger.kernel.org
Subject: Re: [RFC] ethtool: Display reg dump length via get driver info.

On Fri, 2011-03-18 at 16:06 -0500, Ajit Khaparde wrote:
>> Devices like BE store Reg Dump Data in the hardware.

> Where else would it be?

Well yes. That's true.

>> This change will allow to just peek into the hardware
>> to see if any data is available for a dump and analysis,
>> without actually dumping the register data.
> [...]

> This is wrong.  ethtool_ops::get_regs_len really should return a
> constant, otherwise ethtool (and the kernel) cannot allocate a buffer of
> the right size.  If the size of a dump really does vary then make it
> return the maximum possible size for the device.

Yes, it is a constant size. And will always be the max size possible.
I just want to see if I can get the length, without really making the ethtoool -d call.
Because that will trigger the dump too.
At that moment, I may not be interested in the data itself.

-Ajit

> Ben.

--
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.