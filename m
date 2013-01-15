From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 09/10] vmxnet3: use static RSS key
Date: Tue, 15 Jan 2013 19:38:56 +0000
Message-ID: <1358278736.2865.10.camel@bwh-desktop.uk.solarflarecom.com>
References: <1358270915-32758-1-git-send-email-stephen@networkplumber.org>
	 <1358270915-32758-10-git-send-email-stephen@networkplumber.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Shreyas Bhatewara <sbhatewara@vmware.com>,
	<pv-drivers@vmware.com>, <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:13361 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751299Ab3AOTjA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2013 14:39:00 -0500
In-Reply-To: <1358270915-32758-10-git-send-email-stephen@networkplumber.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-01-15 at 09:28 -0800, Stephen Hemminger wrote:
> Rather than generating a different RSS key on each boot, just use
> a predetermined value that will map same flow to same value on
> every device for more predictable testing. This is already done
> on most hardware drivers.
> 
> Initial key value just some arbitrary bits extracted once
> from /dev/random.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
[...]

I agree with the idea, but shouldn't we have just one copy of this key
that drivers can refer to?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
