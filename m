From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] seastar - SeaStar Ethernet driver (review comments
 addressed)
Date: Tue, 2 Feb 2010 17:39:56 -0800
Message-ID: <20100202173956.77b9cf22@nehalam>
References: <20100202205845.GE5246@hawkeye.sandia.gov>
	<1265159307.15726.4.camel@hawkeye.sandia.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Kevin Pedretti" <ktpedre@sandia.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56267 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753211Ab0BCBkX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2010 20:40:23 -0500
In-Reply-To: <1265159307.15726.4.camel@hawkeye.sandia.gov>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2 Feb 2010 18:08:27 -0700
"Kevin Pedretti" <ktpedre@sandia.gov> wrote:

> +
> +/* Rounds up to the nearest quadbyte */
> +#define ROUNDUP4(val)		((val + (4-1)) & ~(4-1))

kernel.h has ALIGN(val, 4) which is same thing.

-- 
