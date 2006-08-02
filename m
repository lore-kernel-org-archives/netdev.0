From: a1 <a1k@mail.ru>
Subject: Re: e1000 speed/duplex error
Date: Wed, 2 Aug 2006 11:34:02 +0400
Message-ID: <168330902.20060802113402@mail.ru>
References: <1301563340.20060801141827@mail.ru>  <9929d2390608010420t60bd44d7o4e522c6edc0a677e@mail.gmail.com>  <793732866.20060801153230@mail.ru>  <9929d2390608010445w4fd81b64g310ae90a423e1a7d@mail.gmail.com>  <911206621.20060801162006@mail.ru> <9929d2390608010534x54324569ja70b1fcbdc23c097@mail.gmail.com> <44CF66AD.1030901@intel.com>
Reply-To: a1 <a1k@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.ru ([194.67.23.122]:7975 "EHLO mx2.mail.ru")
	by vger.kernel.org with ESMTP id S1750854AbWHBHdh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2006 03:33:37 -0400
To: Auke Kok <auke-jan.h.kok@intel.com>
In-Reply-To: <44CF66AD.1030901@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, Auke.

Auke Kok wrote:
AK> Here's that part of the driver documentation:

AK> $ modprobe e1000 AutoNeg=0x08
AK> e1000: 0000:00:00.0: e1000_validate_option: AutoNeg advertising 100/FD


AK>   99 /* Auto-negotiation Advertisement Override
AK> 100  *
AK> 101  * Valid Range: 0x01-0x0F, 0x20-0x2F (copper); 0x20 (fiber)
AK> 102  *
AK> 103  * The AutoNeg value is a bit mask describing which speed and duplex
AK> 104  * combinations should be advertised during auto-negotiation.
AK> 105  * The supported speed and duplex modes are listed below
AK> 106  *
AK> 107  * Bit           7     6     5      4      3     2     1      0
AK> 108  * Speed (Mbps)  N/A   N/A   1000   N/A    100   100   10     10
AK> 109  * Duplex                    Full          Full  Half  Full   Half
AK> 110  *
AK> 111  * Default Value: 0x2F (copper); 0x20 (fiber)
AK> 112  */

This is not what I'm thinking of. Say, for example, I have a bunch of
e1000 adapters in my box and want to dynamically change one's spd/dplx.
For that works in the way you described I need to stop all of them and
load with autoneg parameter (can I pass this parameter only to single
card?) and loose all connection I had on other adapters.
It would be better to handle it in ethtool way, since I discovered
it's a common behavior.
Thanks.


AK> hth,

AK> Auke


-- 
Best Regards,
 Alexandr Kotov                       mailto:a1k@mail.ru

