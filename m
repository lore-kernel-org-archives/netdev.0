From: Michael Buesch <mb@bu3sch.de>
Subject: Re: bcm43xx-d80211 broadcast reception with WPA
Date: Fri, 10 Nov 2006 21:12:32 +0100
Message-ID: <200611102112.33050.mb@bu3sch.de>
References: <ej09qf$2nv$1@sea.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:27541
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1753611AbWKJUOE
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Nov 2006 15:14:04 -0500
To: Paul Hampson <Paul.Hampson@pobox.com>
In-Reply-To: <ej09qf$2nv$1@sea.gmane.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 09 November 2006 23:23, Paul Hampson wrote:
> Hi,
> 
> Long time lurker, first time poster. ^_^
> 
> I've been backporting the bcm43xx-d80211 driver to whatever the released
> 2.6 kernel was using the rt2x00 project's d80211 stack (equivalent to
> current wireless-dev but with a workaround for not having a ieee80211_dev
> pointer and still using the _tfm interface instead of the _cypher interface.)
> 
> As of last night's wireless-dev tree bcm43xx, everything seems to be
> operating fine except incoming broadcast traffic is coming in 14 bytes too
> long and scrambled. I presume this means it's not decrypting properly...

It sounds like a bug in the hardware decryption setup.
Are you using TKIP or not?

Incoming mcast frames are handled in a special way in hardware.
The keyidx field of the packet is used to lookup the key, as
far as I know. (Otherwise the MAC address is used).
Can I see a full dmesg log and a capture log on the broken machine, please?

-- 
Greetings Michael.
