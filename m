From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 (+others ?) and note_interrupt performance hit on
	2.6.30.x
Date: Sun, 26 Jul 2009 11:18:03 +0200
Message-ID: <20090726091803.GA28374@electric-eye.fr.zoreil.com>
References: <4A6BA3CE.9000607@ziu.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Michal Soltys <soltys@ziu.info>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:57962 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752105AbZGZJOd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jul 2009 05:14:33 -0400
Content-Disposition: inline
In-Reply-To: <4A6BA3CE.9000607@ziu.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michal Soltys <soltys@ziu.info> :
[...]
> I did some quick oprofile, and noticed one new call -
> note_interrupt - which wasn't present in the earlier kernel,
> taking majority of the cpu time, relatively to the rest, e.g.:
>
> samples  cum. samples  %        cum. %     symbol name
> 90984    90984         42.8695  42.8695    note_interrupt

May be some screaming irq.

Do your /proc/interrupts look the same with both kernels ?

-- 
Ueimor
