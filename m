From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 crash
Date: Tue, 20 Nov 2007 00:24:49 +0100
Message-ID: <20071119232449.GA8011@electric-eye.fr.zoreil.com>
References: <20071117053920.M40084@nuclearcat.com> <20071117220759.GA2862@electric-eye.fr.zoreil.com> <20071117224224.M6133@nuclearcat.com> <20071118210038.GA5907@electric-eye.fr.zoreil.com> <20071118233010.M61920@nuclearcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys <nuclearcat@nuclearcat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:42918 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750861AbXKSX0x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2007 18:26:53 -0500
Content-Disposition: inline
In-Reply-To: <20071118233010.M61920@nuclearcat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Denys <nuclearcat@nuclearcat.com> :
> Maybe it is good idea to print some registers/etc in watchdog message?
> 
> I will try to reproduce problem with debug enabled, maybe it will be possible 
> to catch problem with more debug. 

Your customers will not necessarily like it but it could be useful to
trace the Rx/Tx descriptor ring content and the irq status word.

If your make it dependent on tp->msg_enable (settable via
'ethtool -s ethX msglvl 65535), you can enable it at will and catch
some bit of normal traffic just before you experiment with the
magic cable.


> On Sun, 18 Nov 2007 22:00:38 +0100, Francois Romieu wrote
> > Denys <nuclearcat@nuclearcat.com> :
[...]
> > I'll take care of it once I am done with the sis190 watchdog failure
> > (nothing hard, simply ugly).

Actually I lack a reliable indication that the Tx process is stuck.
My hack seems able to recover but it can be quite slow to trigger.
A contact at SiS would be welcome.

-- 
Ueimor
