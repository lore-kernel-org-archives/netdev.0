From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: ppp, "Features changed" flooding the log
Date: Fri, 20 May 2011 16:44:23 +0300
Message-ID: <e04d91916983d0a9274087cd2f5ef64d@visp.net.lb>
References: <a08c037f093701d9a2d187d04ac85fee@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rev-153-13.globalproof.net ([194.146.153.13]:53657 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S934097Ab1ETNo2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2011 09:44:28 -0400
In-Reply-To: <a08c037f093701d9a2d187d04ac85fee@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 On Fri, 20 May 2011 16:42:08 +0300, Denys Fedoryshchenko wrote:
> Hi
>
> Is it supposed to be like this?
> [   41.575487] ppp313: Features changed: 0x00006800 -> 0x00006000
> [   41.681499] ppp314: Features changed: 0x00006800 -> 0x00006000
> [   41.796728] ppp315: Features changed: 0x00006800 -> 0x00006000
> [   41.909575] ppp316: Features changed: 0x00006800 -> 0x00006000
> [   42.027802] ppp317: Features changed: 0x00006800 -> 0x00006000
> [   42.142698] ppp318: Features changed: 0x00006800 -> 0x00006000
> [   42.292753] ppp319: Features changed: 0x00006800 -> 0x00006000
> [   42.408706] ppp320: Features changed: 0x00006800 -> 0x00006000
> [   42.544745] ppp321: Features changed: 0x00006800 -> 0x00006000
> [   42.634743] ppp322: Features changed: 0x00006800 -> 0x00006000
> [   42.740747] ppp323: Features changed: 0x00006800 -> 0x00006000
> [   42.856579] ppp324: Features changed: 0x00006800 -> 0x00006000
>
> I guess ppp dropping GSO, but is it should be there on first place?
> GSO is disabled on all ethernet interfaces.
 And as i see GRO enabled there, i guess it can be harmful for shapers, 
 how to disable it?
 NewNet-PPPoE ~ # ethtool -K ppp0 gro off
 Cannot set device GRO settings: Operation not supported
 Or there is no need for that?
