From: Jamie Iles <jamie@jamieiles.com>
Subject: Re: [PATCH 8/8] macb: support data bus widths > 32 bits
Date: Fri, 11 Mar 2011 13:15:20 +0000
Message-ID: <20110311131520.GC7357@pulham.picochip.com>
References: <1299751843-9743-1-git-send-email-jamie@jamieiles.com>
 <1299751843-9743-9-git-send-email-jamie@jamieiles.com>
 <20110311125523.GN9351@game.jcrosoft.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamie Iles <jamie@jamieiles.com>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, nicolas.ferre@atmel.com
To: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:42207 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753265Ab1CKNP2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2011 08:15:28 -0500
Received: by bwz15 with SMTP id 15so2655178bwz.19
        for <netdev@vger.kernel.org>; Fri, 11 Mar 2011 05:15:26 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20110311125523.GN9351@game.jcrosoft.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 11, 2011 at 01:55:23PM +0100, Jean-Christophe PLAGNIOL-VILLARD wrote:
> On 10:10 Thu 10 Mar     , Jamie Iles wrote:
> > Some GEM implementations may support data bus widths up to 128 bits.
> > Allow the platform data to specify the data bus width and let the driver
> > program it up.
> > 
> can we detect it?

Well, the first design configuration register will tell you what the 
maximum data bus width is so we could probably always go with that.  I 
can't think of a good reason why you wouldn't want to do that.

Jamie
