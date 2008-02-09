From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH][AX25] ax25_ds_timer: use mod_timer instead of add_timer
Date: Sat, 9 Feb 2008 20:39:05 +0100
Message-ID: <20080209193905.GA2754@ami.dom.local>
References: <47664A0C.4060903@free.fr> <20071218135202.GA2023@ff.dom.local> <47ADF4A2.6070705@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ralf Baechle DL5RB <ralf@linux-mips.org>,
	Jann Traschewski <jann@gmx.de>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Bernard Pidoux F6BVP <f6bvp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:3109 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753076AbYBITf6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Feb 2008 14:35:58 -0500
Received: by ug-out-1314.google.com with SMTP id z38so84837ugc.16
        for <netdev@vger.kernel.org>; Sat, 09 Feb 2008 11:35:56 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <47ADF4A2.6070705@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 09, 2008 at 07:44:50PM +0100, Bernard Pidoux F6BVP wrote:
> Hi,
>
> With AX25 patches applied I still get this possible circular locking  
> message.

Hi Bernard,

Could you confirm which exactly patches did you try? Is this vanilla
2.6.24 plus these two: ax25_timer and ax25_ds_timer or something more?
And I'm not sure what do you mean by "still": the warning came back
just after these last patches? At least these timer patches don't seem
to change anything around locking?

Thanks for testing this,
Jarek P.
