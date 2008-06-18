From: "Grant Likely" <grant.likely@secretlab.ca>
Subject: Re: [PATCH 1/2] fs_enet: fix checkpatch.pl problems
Date: Tue, 17 Jun 2008 23:20:21 -0600
Message-ID: <fa686aa40806172220u13d4397cn51f7f98e020408aa@mail.gmail.com>
References: <1213743794-3537-1-git-send-email-jrigby@freescale.com>
	 <1213743794-3537-2-git-send-email-jrigby@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Scott Wood" <scottwood@freescale.com>, linuxppc-dev@ozlabs.org,
	jeff@garzik.org, "Sam Ravnborg" <sam@ravnborg.org>,
	netdev@vger.kernel.org
To: "John Rigby" <jrigby@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.243]:20381 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753540AbYFRFUf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 01:20:35 -0400
Received: by an-out-0708.google.com with SMTP id d40so20952and.103
        for <netdev@vger.kernel.org>; Tue, 17 Jun 2008 22:20:34 -0700 (PDT)
In-Reply-To: <1213743794-3537-2-git-send-email-jrigby@freescale.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 17, 2008 at 5:03 PM, John Rigby <jrigby@freescale.com> wrote:
> Fixed all errors and warnings that checkpatch.pl
> reports if this was a new submission.
> Also changed instances of fec_t to struct fec in
> mac-fec.c and mii-fec.c.

Nit: checkpatch is not law; particularly in the case of whitespace
change.  Personally, I think cleaning up whitespace in this regard
causes more problems than it solves.  Plus, it makes the important
change (fec_t -> struct fec) get lost in a see of unimportant ones
which makes for hard reviewing.

But I must sleep now; I'll review your other patch tomorrow.

Cheers,
g.

-- 
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
