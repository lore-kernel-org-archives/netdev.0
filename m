From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [RFT] Realtek 8168 ethernet support
Date: Tue, 13 Jun 2006 00:29:47 +0200
Message-ID: <20060612222947.GC803@electric-eye.fr.zoreil.com>
References: <20060608143133.7e36a0b7.rdunlap@xenotime.net> <4488DF85.3090901@garzik.org> <20060609183358.GA5835@electric-eye.fr.zoreil.com> <4489C290.6020705@garzik.org> <20060610120523.GA24288@electric-eye.fr.zoreil.com> <20060610224811.GA3256@electric-eye.fr.zoreil.com> <20060611233022.GA11776@electric-eye.fr.zoreil.com> <448D4236.9050505@aquazul.com> <20060612184941.GA803@electric-eye.fr.zoreil.com> <448DE38D.8070503@aquazul.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:39910 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S932613AbWFLWdE
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jun 2006 18:33:04 -0400
To: Mourad De Clerck <mourad@aquazul.com>
Content-Disposition: inline
In-Reply-To: <448DE38D.8070503@aquazul.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mourad De Clerck <mourad@aquazul.com> :
[...]
> I do notice a pattern with more and less "complicated"/cpu intensive
> traffic: using http (wget) I manage to finish doing the transfer of the
> same reasonably big file. With scp I only manage to get to 90% of that
> file before it freezes - I should still test whether I can get a http
> transfer to lock up if I use a (much) bigger file.

wget goes faster, right ? Do you have some vmstat 1 output at hand
for it ?

[...]
> > Unrelated: have you checked the link setting ?
> 
> ethtool reports "Link detected: yes" and so does my switch.

Ok but can you set correctly the link with the command which was told
to fail in you first mail ? The patch could fix it.

[...]
> shuttle:~# scp hell:/srv/bigfile.bin .
> bigfile.bin                                   90%  155MB  17.5MB/s   00:00 ETA

Can you try something like:
dd if=/dev/zero bs=1024k count=1000 | ssh -c blowfish hell dd of=/tmp/1000m.bin 

May I assume that the freeze locks everything (keyboard, mouse, led) beyond
the scp command itself ?

-- 
Ueimor
