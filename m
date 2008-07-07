From: Ben Greear <greearb@candelatech.com>
Subject: Re: Wrong padding of short packets send by a tagged-vlan interface?
Date: Mon, 07 Jul 2008 14:06:23 -0700
Message-ID: <4872854F.80603@candelatech.com>
References: <Pine.LNX.4.64.0807072210470.15459@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: Krzysztof Oledzki <olel@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([66.165.47.212]:37880 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755846AbYGGVGf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 17:06:35 -0400
In-Reply-To: <Pine.LNX.4.64.0807072210470.15459@bizon.gios.gov.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krzysztof Oledzki wrote:
> Hello,
> 
> I have a problem that I'm not able to connect from selected linux hosts 
> to a newly installed Netware 6.5 server. After two days of debugging I 
> discovered that the problem seems to be caused by an insufficient 
> padding of a .1q tagged packets.

Last time this came up I looked up the RFC and according to it
there is no need to pad beyond the normal 60 + 4, vlan tag or
not.

This is a bug in your intervening switch and/or Netware unless you actually see packets
leaving Linux with less than 60 + 4 bytes.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

