From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: sky2 panic in 2.6.32.1 under load (new oops)
Date: Tue, 29 Dec 2009 23:59:42 -0800
Message-ID: <20091229235942.51bf733d@nehalam>
References: <4B300A2A.8040305@gmail.com>
	<4B300E30.9090707@majjas.com>
	<4B3114E3.1070602@majjas.com>
	<4B329FA3.9090904@majjas.com>
	<20091223230102.4bb0100e.akpm@linux-foundation.org>
	<4B34E847.8010809@majjas.com>
	<20091225152200.1cf11dfe@nehalam>
	<4B3581C7.8000702@majjas.com>
	<20091226095723.7ac82b18@nehalam>
	<4B367409.5060202@majjas.com>
	<4B379378.4000102@majjas.com>
	<20091227102238.0df149f9@nehalam>
	<4B37B7E2.5070307@majjas.com>
	<20091229093023.3ad24786@nehalam>
	<4B3A5048.9090700@majjas.com>
	<20091229114938.1f4d1c5c@nehalam>
	<4B3AFFE8.3060409@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"Berck E. Nash" <flyboy@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Michael Breuer <mbreuer@majjas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35956 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751510AbZL3H77 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Dec 2009 02:59:59 -0500
In-Reply-To: <4B3AFFE8.3060409@majjas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 30 Dec 2009 02:23:20 -0500
Michael Breuer <mbreuer@majjas.com> wrote:

> And got this:
> Dec 30 02:17:23 mail kernel: sky2 0000:06:00.0: error interrupt 
> status=0x40000008
> Dec 30 02:17:23 mail kernel: sky2 0000:06:00.0: error interrupt 
> status=0x40000008
> Dec 30 02:17:23 mail kernel: sky2 Tx ring pending=28...30 report=29 done=29
> Dec 30 02:17:23 mail kernel: sky2 Tx ring pending=28...30 report=29 done=29
> Dec 30 02:17:23 mail kernel: sky2 0000:06:00.0: error interrupt status=0x8
> Dec 30 02:17:23 mail kernel: sky2 0000:06:00.0: error interrupt status=0x8
> Dec 30 02:17:23 mail kernel: sky2 Tx ring pending=30...32 report=30 done=31
> Dec 30 02:17:23 mail kernel: sky2 Tx ring pending=30...32 report=30 done=31

The interesting bits are only output at DEBUG level.  So either change kernel
log level or syslog.

-- 
