From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 04/10] batman-adv: export compatibility version via
 debugfs
Date: Mon, 19 Nov 2012 18:52:30 +0000
Message-ID: <1353351150.4156.4.camel@bwh-desktop.uk.solarflarecom.com>
References: <1353313451-2930-1-git-send-email-ordex@autistici.org>
	 <1353313451-2930-5-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<b.a.t.m.a.n@lists.open-mesh.org>,
	Marek Lindner <lindner_marek@yahoo.de>
To: Antonio Quartulli <ordex@autistici.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:32719 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753987Ab2KSSwe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 13:52:34 -0500
In-Reply-To: <1353313451-2930-5-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-11-19 at 09:24 +0100, Antonio Quartulli wrote:
> Different versions of the batman-adv module may use the same compatibility
> version, but this is not understandable at runtime (the only way is to parse the
> kernel log and fetch the batman-adv advertisement message on loading). The user
> may want to know whether two nodes using different versions can communicate or
> not. For this purpose the module has to export this value through debugfs.
[...]

I do hope that you're not planning to use unstable debugfs interfaces
indefinitely.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
