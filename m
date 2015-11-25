From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: Kernel 4.1.12 crash
Date: Wed, 25 Nov 2015 15:10:48 +0100
Message-ID: <20151125141048.GA3868@alphalink.fr>
References: <564F26FF.3040605@seti.kr.ua>
 <564FA904.7020603@gmail.com>
 <5650287B.9070901@seti.kr.ua>
 <56514FF5.7060906@gmail.com>
 <5654EBE8.9030705@seti.kr.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Duyck <alexander.duyck@gmail.com>, netdev@vger.kernel.org
To: Andrew <nitr0@seti.kr.ua>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:57059 "EHLO
	zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754441AbbKYOKw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2015 09:10:52 -0500
Content-Disposition: inline
In-Reply-To: <5654EBE8.9030705@seti.kr.ua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 25, 2015 at 12:59:52AM +0200, Andrew wrote:
> Hi.
> 
> I tried to reproduce errors in virtual environment (some VMs on my
> notebook).
> 
> I've tried to create 1000 client PPPoE sessions from this box via script:
> for i in `seq 1 1000`; do pppd plugin rp-pppoe.so user test password test
> nodefaultroute maxfail 0 persist nodefaultroute holdoff 1 noauth eth0; done
> 
I've tried to reproduce the bug with your script, but couldn't get
anything to crash (VM is Debian Jessie i386 running on KVM with upstream
kernel 4.1.12). Does the crash happen before all sessions get
established?

Can you reliably reproduce the bug? If so can you please try with 4.3?
It contains ppp fixes not included in 4.1.12.
