From: "Bob Copeland" <me@bobcopeland.com>
Subject: Re: [PATCH] wireless: fix regression caused by regulatory config option
Date: Tue, 28 Oct 2008 11:13:20 -0400
Message-ID: <b6c5339f0810280813k4b378678ic10d26281bf4f170@mail.gmail.com>
References: <20081026103024.2712ddc9@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, rjw@sisk.pl, rodriguez@atheros.com,
	johannes@sipsolutions.net
To: "Arjan van de Ven" <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.224]:39829 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751673AbYJ1PNV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 11:13:21 -0400
In-Reply-To: <20081026103024.2712ddc9@infradead.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -         Say N unless you cannot install a new userspace application
> -         or have one currently depending on the ieee80211_regdom module
> -         parameter and cannot port it to use the new userspace interfaces.
> -
> -         This is scheduled for removal for 2.6.29.
> +         Say Y unless you have installed a new userspace application.
> +         Also say Y if have one currently depending on the ieee80211_regdom
> +         module parameter and cannot port it to use the new userspace
> +         interfaces.

Ignoring the main debate :) -- I might point out the actual help text here in
is a bit user-unfriendly.  "installed a new userspace application" (which? I
just installed Firefox, does that count?)  "Also say Y if [you] have [an
application]..."

-- 
Bob Copeland %% www.bobcopeland.com
