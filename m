From: "Grant Likely" <grant.likely@secretlab.ca>
Subject: Re: [PATCH] phylib: Don't allow core of phylib to build as a module
Date: Fri, 6 Jun 2008 09:19:50 -0600
Message-ID: <fa686aa40806060819t75c1c0b0h303ff37d387b2373@mail.gmail.com>
References: <Pine.LNX.4.64.0806021019540.22439@blarg.am.freescale.net>
	 <484419EE.5040503@garzik.org>
	 <1E4EB64C-0618-497E-AABC-74EB7D74B97F@kernel.crashing.org>
	 <48442239.7090906@garzik.org>
	 <BF15FEBB-4876-4B16-915B-1D21BF989DA8@kernel.crashing.org>
	 <83820D83-487C-4586-9867-F4226A87A276@freescale.com>
	 <48445851.4090105@garzik.org>
	 <095F258F-72DD-4F27-A457-A57D9FAA1E76@kernel.crashing.org>
	 <48448020.5020407@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Kumar Gala" <galak@kernel.crashing.org>, netdev@vger.kernel.org,
	"Jeff Garzik" <jeff@garzik.org>, linuxppc-dev@ozlabs.org
To: "Scott Wood" <scottwood@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ag-out-0708.google.com ([72.14.246.244]:45236 "EHLO
	ag-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758208AbYFFPTw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2008 11:19:52 -0400
Received: by ag-out-0708.google.com with SMTP id 31so3262471agc.10
        for <netdev@vger.kernel.org>; Fri, 06 Jun 2008 08:19:51 -0700 (PDT)
In-Reply-To: <48448020.5020407@freescale.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 2, 2008 at 5:20 PM, Scott Wood <scottwood@freescale.com> wrote:
> Kumar Gala wrote:
>> I think we'd be better off with a small stub that is always built into the
>> kernel for phy_read/phy_write, etc or the function pointer indirection
>> mechanism.
>
> And then instead of build failures, you'd get a silent runtime failure to
> apply the workaround if phylib is built as a module.

Indeed; I vote for the build failure over the silent runtime failure.
If a platform needs it and does not select it, then the platform is
broken and it is a bug.

Cheers,
g.

-- 
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
