From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: TCP-MD5 checksum failure on x86_64 SMP
Date: Tue, 04 May 2010 12:32:02 +0100
Message-ID: <1272972722.2097.1.camel@achroite.uk.solarflarecom.com>
References: <i2h571fb4001005031027y4a58c4dtfd28ddcdc08d8401@mail.gmail.com>
	 <o2h571fb4001005032030tdf02a4fag520ec4e56ebdb8df@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Bhaskar Dutta <bhaskie@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:56218 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752058Ab0EDLcF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 May 2010 07:32:05 -0400
In-Reply-To: <o2h571fb4001005032030tdf02a4fag520ec4e56ebdb8df@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-05-04 at 09:00 +0530, Bhaskar Dutta wrote:
> Hi,
> 
> I am observing intermittent TCP-MD5 checksum failures
> (CONFIG_TCP_MD5SIG)  on kernel 2.6.31 while talking to a BGP router.
> 
> The problem is only seen in multi-core 64 bit machines.
> Is there any known bug in the per_cpu_ptr implementation (I am aware
> that the percpu allocator has been re-implemented in 2.6.33) that
> might cause a corruption in 64 bit SMP machines?
> 
> Any pointers would be appreciated.

There was another recent report of incorrect MD5 signatures in
<http://thread.gmane.org/gmane.linux.network/159556>, but without any
response.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

