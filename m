From: Stuart Hodgson <smhodgson@solarflare.com>
Subject: Re: [PATCH ethtool] Add command to dump module EEPROM
Date: Mon, 14 May 2012 16:36:30 +0100
Message-ID: <4FB1267E.2090006@solarflare.com>
References: <1337008431-6304-1-git-send-email-yanivr@broadcom.com> <1337005139.2550.6.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Yaniv Rosner <yanivr@broadcom.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Eilon Greenstein <eilong@broadcom.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:56609 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756983Ab2ENPlz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2012 11:41:55 -0400
In-Reply-To: <1337005139.2550.6.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/05/12 15:18, Ben Hutchings wrote:
> On Mon, 2012-05-14 at 18:13 +0300, Yaniv Rosner wrote:
>> Hi Ben,
>> This patch adds a new option to dump (SFP+, XFP, ...) module EEPROM following
>> recent support to kernel side. Below some examples:
>>
>> bash-3.00# ethtool -m eth1 offset 0x14 length 32 raw on
>> JDSU            PLRXPLSCS432
>>
>> bash-3.00# ethtool -m eth1 offset 0x14 length 32
>> Offset          Values
>> ------          ------
>> 0x0014          4a 44 53 55 20 20 20 20 20 20 20 20 20 20 20 20
>> 0x0024          00 00 01 9c 50 4c 52 58 50 4c 53 43 53 34 33 32
>>
>> Please consider applying to ethtool.
> 
> I agree there should be ASCII-hex and binary dump modes, but we should
> also support decoding of recognised EEPROM types (as Stuart proposed
> earlier).

I have a patch to do this as well, but also parse the SFP+ EEPROM.
I need to fix it up after some of the changes to the patches that added
kernel support but can submit in the next day or so if this would be of
use.

Stu
