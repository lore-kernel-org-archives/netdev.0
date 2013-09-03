From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: VLAN HW accel, performance advantage?
Date: Tue, 3 Sep 2013 14:50:16 +0100
Message-ID: <1378216216.1545.1.camel@bwh-desktop.uk.level5networks.com>
References: <OF00E35E7C.7482EC01-ONC1257BDB.00314AD0-C1257BDB.0031F6D0@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:45972 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932904Ab3ICNuY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 09:50:24 -0400
In-Reply-To: <OF00E35E7C.7482EC01-ONC1257BDB.00314AD0-C1257BDB.0031F6D0@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-09-03 at 11:05 +0200, Joakim Tjernlund wrote:
> I am considering impl. VLAN HW acceleration in Freescales ucc_geth driver 
> to improve
> performance, primarily for bridged interfaces.
>  I am hoping the community has some insights as to what performance gains 
> one
> could expect?

At the moment you need to do VLAN RX offload (or fake it in software) to
take advantage of GRO for VLAN-encapsulated packets.  Other than that, I
don't think it makes a lot of difference in most situations.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
