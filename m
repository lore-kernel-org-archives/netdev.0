From: rgh <birrachiara@tin.it>
Subject: Re: [PATCH 2/3] sis190: fix gigabit negotiation
Date: Wed, 03 Jun 2009 08:15:16 +0200
Message-ID: <4A2614F4.9050304@tin.it>
References: <cover.1244012631.git.birrachiara@tin.it> <20090603095252.GA15419@localhost> <20090602213857.GB26871@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vsmtp14.tin.it ([212.216.176.118]:48831 "EHLO vsmtp14.tin.it"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752275AbZFCGPQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jun 2009 02:15:16 -0400
In-Reply-To: <20090602213857.GB26871@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu wrote:
> Riccardo Ghetta <birrachiara@tin.it> :
>> Fixes an initialization error; the chip negotiates gigabit, but
>> the driver mistakenly handled it as 100Mb.
> 
> Did you draw some inspiration from SiS own driver ? If so it would
> deserve to be quoted.
> 
Yes, I looked at both sis and forcedeth drivers. I'll quote both.

> val has been read from the LPA register.
> 
> s/ADVERTISE_NPAGE/LPA_NPAGE/ ?
Uhu, yes, sorry.


