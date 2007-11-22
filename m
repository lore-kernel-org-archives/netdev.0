From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH RFC] [1/9] Core module symbol namespaces code and intro.
Date: Thu, 22 Nov 2007 19:19:10 +0100
Message-ID: <200711221919.11071.ak@suse.de>
References: <20071122343.446909000@suse.de> <200711221456.22297.rusty@rustcorp.com.au> <a8e1da0711220041v3d3c27d2pf7f326185666420d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Rusty Russell" <rusty@rustcorp.com.au>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, sam@ravnborg.org
To: "Dave Young" <hidave.darkstar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:60395 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752064AbXKVSXj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Nov 2007 13:23:39 -0500
In-Reply-To: <a8e1da0711220041v3d3c27d2pf7f326185666420d@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Andy, I like your idea.  IMHO, as Rusty said a simple EXPORT_SYMBOL_TO
> is better.

I don't think so. e.g. tcpcong would be very very messy this way.

> And I wonder if it is possible to export to something like  the struct
> device_driver? If it's possible then it will not limited to modules.

Not sure I follow you. Can you expand? 

-Andi
