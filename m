From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] starfire: Clean up properly if firmware loading fails
Date: Tue, 26 Jan 2010 14:40:28 +0000
Message-ID: <1264516828.2782.6.camel@achroite.uk.solarflarecom.com>
References: <bug-15091-10286@http.bugzilla.kernel.org/>
	 <20100125170816.db9435ed.akpm@linux-foundation.org>
	 <1264471333.373.349.camel@localhost>
	 <20100125181508.790010cb.akpm@linux-foundation.org>
	 <1264473168.373.354.camel@localhost> <4B5E5A5F.90608@moffatt.org.nz>
	 <20100125192839.7eaceb2b.akpm@linux-foundation.org>
	 <4B5E82CB.6040001@moffatt.org.nz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Alan Cox <alan@lxorguk.ukuu.org.uk>, stable@kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Michael <michael@moffatt.org.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:32629 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753840Ab0AZOke (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jan 2010 09:40:34 -0500
In-Reply-To: <4B5E82CB.6040001@moffatt.org.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-01-26 at 18:51 +1300, Michael wrote:
[...]
> I will have to find a cleverer way to copy over the new firmware libs 
> for future compiles. The 'make install' seems to copy firmware objects 
> into the compiling system's /lib/firmware/ directory without 
> distinguishing the kernel version. So I can't easily tell which ones I'm 
> supposed to be copying into the nfs export.
[...]

You should be setting INSTALL_MOD_PATH.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

