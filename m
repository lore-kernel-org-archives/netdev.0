From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: sky2 rx errors printing to the console
Date: Wed, 15 Oct 2008 15:05:30 +0100
Message-ID: <1224079530.3984.180.camel@achroite>
References: <76366b180810150640h230ee681wd9cb474dbe4c7045@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andrew Paprocki <andrew@ishiboo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:34555 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755280AbYJOOFf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2008 10:05:35 -0400
In-Reply-To: <76366b180810150640h230ee681wd9cb474dbe4c7045@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-10-15 at 14:40 +0100, Andrew Paprocki wrote:
> Does anyone know if these status values imply what is wrong? Could
> this be caused by a faulty cable?

Looking at the code around this message, it appears that least
over/under-length, framing and CRC errors (and maybe others) can trigger
this.  A faulty cable could certainly result in these sorts of errors,
most likely CRC errors.

"grep -r . /sys/class/net/eth0/statistics/" will show you detailed error
statistics for eth0.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

