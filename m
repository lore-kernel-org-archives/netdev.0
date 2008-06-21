From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: bnx2_poll panicking kernel
Date: Sat, 21 Jun 2008 09:11:05 -0700
Message-ID: <C27F8246C663564A84BB7AB343977242019B6FEC8E@IRVEXCHCCR01.corp.ad.broadcom.com>
References: <20080621113406.5f89ae8d.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "Ben Hutchings" <bhutchings@solarflare.com>,
	netdev <netdev@vger.kernel.org>,
	"mirrors@debian.org" <mirrors@debian.org>
To: "'Bill Fink'" <billfink@mindspring.com>,
	"Josip Rodin" <joy@entuzijast.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1607 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751212AbYFUQLb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jun 2008 12:11:31 -0400
In-Reply-To: <20080621113406.5f89ae8d.billfink@mindspring.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bill Fink wrote:

>
> Wouldn't the "modprobe -r bnx2" destroy the HTB info for that device?
>
>

I think it would.  Josip, you can do "tc -d class show dev eth0" to
check.

