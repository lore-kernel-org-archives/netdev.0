From: Brice Goglin <Brice.Goglin@ens-lyon.org>
Subject: Re: My e1000e GBE card is eating all port 623 pks
Date: Wed, 25 Apr 2012 11:57:47 +0200
Message-ID: <4F97CA9B.3060105@ens-lyon.org>
References: <OF8F83D7F0.387F6CCE-ONC12579E7.0049B885-C12579E7.004A4356@transmode.se> <20120424145128.000070a8@unknown> <OF497D4E52.CC9EA3C0-ONC12579EB.0031DCB3-C12579EB.003213E4@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpfb1-g21.free.fr ([212.27.42.9]:57843 "EHLO
	smtpfb1-g21.free.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757503Ab2DYJ6g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 05:58:36 -0400
Received: from smtp2-g21.free.fr (smtp2-g21.free.fr [212.27.42.2])
	by smtpfb1-g21.free.fr (Postfix) with ESMTP id 0C7C52E0F7
	for <netdev@vger.kernel.org>; Wed, 25 Apr 2012 11:58:31 +0200 (CEST)
In-Reply-To: <OF497D4E52.CC9EA3C0-ONC12579EB.0031DCB3-C12579EB.003213E4@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25/04/2012 11:06, Joakim Tjernlund wrote:
> Jesse Brandeburg<jesse.brandeburg@intel.com>  wrote on 2012/04/24 23:51:28:
>> On Sat, 21 Apr 2012 15:31:09 +0200
>> Joakim Tjernlund<joakim.tjernlund@transmode.se>  wrote:
>>
>>> Looks like port 623 is some mgmt protocol and our e1000e boards are eating these
>>> pkgs and this trips NIS, finger and yptest hangs for a long time before timing out and
>>> moving on.
>>>
>>> Is there a way to tell the network stack not to eat port 623 pkgs or
>>> have NIS not to use port 623?
>> I think you might be looking for something like portreserve
>> (see man portreserve)
> Seen portreserve on the web(gentoo does not have it) but it seems like a workaround.
> Should not eating port 623 be something one should turn on? Now it is default on
> and I cannot find a way to turn it off.
>

It might be related to IPMI (UDP/623 iirc). Try looking in your BIOS 
and/or network firmware config at boot, there might be things to disable 
there.

Brice
