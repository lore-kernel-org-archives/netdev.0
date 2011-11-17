From: Matthew Garrett <mjg59@srcf.ucam.org>
Subject: Re: [PATCH] r8169: add module param for control of ASPM disable
Date: Thu, 17 Nov 2011 21:26:33 +0000
Message-ID: <20111117212633.GA21564@srcf.ucam.org>
References: <1321052755-15368-1-git-send-email-tbroch@chromium.org>
 <20111112045935.GA24292@srcf.ucam.org>
 <20111112104624.GA24870@electric-eye.fr.zoreil.com>
 <CA+iF6Rog3ptpmQZzhcRODmZUKN18_uw5t9xfpQjbJ86qKUA0eQ@mail.gmail.com>
 <20111117093724.GB9112@electric-eye.fr.zoreil.com>
 <CA+iF6RqKScip+6w-tzo3sF+hEsYDUefED29KEBrx5TDaZaTEbA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>
To: Todd Broch <tbroch@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cavan.codon.org.uk ([93.93.128.6]:35053 "EHLO
	cavan.codon.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752144Ab1KQV0i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 16:26:38 -0500
Content-Disposition: inline
In-Reply-To: <CA+iF6RqKScip+6w-tzo3sF+hEsYDUefED29KEBrx5TDaZaTEbA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 17, 2011 at 01:20:46PM -0800, Todd Broch wrote:

> Looking a bit more at the driver a lot of configuration / feature choice is
> tied to mac_version.  Would this be a better solution (partial patch ...
> will submit properly later)

I'd be mildly surprised if the mac's the relevant constraint here, 
although it's possible. This patch is almost certainly safe, but if 
you're able to check with the hardware vendor you're working with that 
would be even better.

-- 
Matthew Garrett | mjg59@srcf.ucam.org
