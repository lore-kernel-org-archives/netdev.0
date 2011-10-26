From: Linus Walleij <linus.walleij@stericsson.com>
Subject: Re: [PATCH 2/2] net/smsc911x: Add regulator support
Date: Wed, 26 Oct 2011 12:44:06 +0200
Message-ID: <4EA7E476.7030608@stericsson.com>
References: <1319616356-6391-1-git-send-email-linus.walleij@stericsson.com> <20111026083838.GA9157@opensource.wolfsonmicro.com> <4EA7D1F5.2030904@stericsson.com> <20111026101750.GA2921@opensource.wolfsonmicro.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Steve Glendinning <steve.glendinning@smsc.com>,
	Mathieu Poirer <mathieu.poirier@linaro.org>,
	Robert MARKLUND <robert.marklund@stericsson.com>,
	Linus Walleij <linus.walleij@linaro.org>
To: Mark Brown <broonie@opensource.wolfsonmicro.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog101.obsmtp.com ([207.126.144.111]:47960 "EHLO
	eu1sys200aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932634Ab1JZKyR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2011 06:54:17 -0400
In-Reply-To: <20111026101750.GA2921@opensource.wolfsonmicro.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/26/2011 12:17 PM, Mark Brown wrote:
>> Then we have platforms with regulator support, but no
>> regulator for this hardware, because that one happens
>> to be always-on in these systems.
>>      
> Right, this is extremely common and is exactly what the fixed voltage
> regulator is there for - if you've got an always on regulator in your
> system define a fixed voltage regulator to represent it.
>    

Aha you mean I need to go into the platform/board files
for all systems using the smsc911x and add a fixed voltage
regulator?

OK that can't be too hard...

Yours,
Linus Walleij
