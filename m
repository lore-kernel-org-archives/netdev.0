From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/8] can: CAN Network device driver and SYSFS interface
Date: Fri, 20 Feb 2009 10:44:59 +0100
Message-ID: <499E7B9B.6030603@trash.net>
References: <1235070082-7069-1-git-send-email-wg@grandegger.com> <1235070082-7069-2-git-send-email-wg@grandegger.com> <1235070082-7069-3-git-send-email-wg@grandegger.com> <1235070082-7069-4-git-send-email-wg@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44940 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753967AbZBTJpD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2009 04:45:03 -0500
In-Reply-To: <1235070082-7069-4-git-send-email-wg@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wolfgang Grandegger wrote:
> The CAN network device driver interface provides a generic interface to
> setup, configure and monitor CAN network devices. It exports a set of
> common data structures and functions, which all real CAN network device
> drivers should use. Please have a look to the SJA1000 or MSCAN driver
> to understand how to use them. The name of the module is can-dev.ko.
> 
> Furthermore adds a SYSFS interface to set and get CAN device properties.
> When the CAN device is registered, a set of SYSFS files is created in
> "/sys/class/net/canX/". These files allow to set and get device
> properties like bit-timing parameters, state, controller mode and CAN
> statistics.

Is sysfs really the best choice for this? It has the usual problems,
you can't change multiple parameters at once atomically. Now, I don't
know whether this is actually (and currently) a problem for CAN, but
given that we already have a generic netlink interface for creating
network interfaces that can easily support this, what are the reasons
for adding a new interface instead of using the existing one?
