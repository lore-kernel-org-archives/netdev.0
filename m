From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [RFT] Realtek 8168 ethernet support
Date: Mon, 12 Jun 2006 20:49:41 +0200
Message-ID: <20060612184941.GA803@electric-eye.fr.zoreil.com>
References: <20060601200200.A0E0689D05D@zog.reactivated.net> <20060608143133.7e36a0b7.rdunlap@xenotime.net> <4488DF85.3090901@garzik.org> <20060609183358.GA5835@electric-eye.fr.zoreil.com> <4489C290.6020705@garzik.org> <20060610120523.GA24288@electric-eye.fr.zoreil.com> <20060610224811.GA3256@electric-eye.fr.zoreil.com> <20060611233022.GA11776@electric-eye.fr.zoreil.com> <448D4236.9050505@aquazul.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:11413 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1752162AbWFLSxM
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jun 2006 14:53:12 -0400
To: Mourad De Clerck <mourad@aquazul.com>
Content-Disposition: inline
In-Reply-To: <448D4236.9050505@aquazul.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mourad De Clerck <mourad@aquazul.com> :
[...]
> I just tried this patch set, but it doesn't do anything for the "freeze
> at high speed" I mentioned on 2006-06-09. It still locks up. (As an
> additional data point: I installed win2k on this machine, and it seems
> to have no problems transferring at high speeds. Just wanted to try to
> rule out faulty hardware.)

Please send .config and complete dmesg (starting with 'Linux version ...').
The output of a 'vmstat 1' until it freezes could give some hint.
So could trying a different PCI slot. How do you generate traffic ?

15Mo/s of usual traffic means roughly 1000pps. It is not really high speed.

Unrelated: have you checked the link setting ?

-- 
Ueimor
