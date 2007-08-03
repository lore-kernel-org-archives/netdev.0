From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [patch 0/5][RFC] Update network drivers to use devres
Date: Fri, 3 Aug 2007 09:58:57 +0100
Message-ID: <20070803095857.5fb3f368@oldman.hamilton.local>
References: <20070802224206.GB5181@ifup.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, teheo@suse.de
To: Brandon Philips <brandon@ifup.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:41968 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755749AbXHCI6i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2007 04:58:38 -0400
In-Reply-To: <20070802224206.GB5181@ifup.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2 Aug 2007 15:42:06 -0700
Brandon Philips <brandon@ifup.org> wrote:

> This patch set adds support for devres in the net core and converts the
> e100 and e1000 drivers to devres.  Devres is a simple resource manager
> for device drivers, see Documentation/driver-model/devres.txt for more
> information.
> 
> The use of devres will remain optional for drivers with this patch set.
> Drivers can be converted when it makes sense.

Just because devres exists is not sufficient motivation to change.

It seems that devres was a band-aid rather than fixing storage drivers
to have proper DMA lifetimes. 
Network devices seem to work fine thanks, and the resource requirements
are different. If ain't broke, don't fix it.
