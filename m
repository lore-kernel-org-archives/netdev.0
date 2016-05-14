From: Guy Harris <guy@alum.mit.edu>
Subject: Re: What ixgbe devices support HWTSTAMP_FILTER_ALL for hardware time stamping?
Date: Fri, 13 May 2016 19:23:36 -0700
Message-ID: <076DDE1B-C6F3-43FD-94BE-1EAF15726383@alum.mit.edu>
References: <582A121C-339D-4469-958C-9673C7E5A654@alum.mit.edu>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
To: Network Development <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from c.mail.sonic.net ([64.142.111.80]:39028 "EHLO c.mail.sonic.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753551AbcENCXj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 22:23:39 -0400
Received: from [192.168.42.66] (173-228-4-107.dsl.dynamic.fusionbroadband.com [173.228.4.107])
	(authenticated bits=0)
	by c.mail.sonic.net (8.15.1/8.15.1) with ESMTPSA id u4E2Nal1030531
	(version=TLSv1 cipher=DHE-RSA-AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 13 May 2016 19:23:37 -0700
In-Reply-To: <582A121C-339D-4469-958C-9673C7E5A654@alum.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On May 13, 2016, at 4:12 PM, Guy Harris <guy@alum.mit.edu> wrote:

> 	drivers/net/ethernet/freescale/gianfar*.c
> 
> reports HWTSTAMP_FILTER_ALL even if the device doesn't have FSL_GIANFAR_DEV_HAS_TIMER set so that it claims that devices without a timer can do hardware timestamping,

Nope - I checked, and it doesn't claim to support any hardware timestamping at all if it doesn't have FSL_GIANFAR_DEV_HAS_TIMER set, so that *particular* driver is OK.
