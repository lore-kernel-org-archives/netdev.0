From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [Bugme-new] [Bug 9391] New: Netgear GA320T(tg3) strange
 errors and non-workingness
Date: Fri, 16 Nov 2007 08:55:42 -0800
Message-ID: <1551EAE59135BE47B544934E30FC4FC002AABB2E@nt-irva-0751.brcm.ad.broadcom.com>
References: <cccedfc60711160608j1ff89979uf7c1f122dd050adc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	"Andrew Morton" <akpm@linux-foundation.org>
To: "Jon Nelson" <jnelson@jamponi.net>,
	"Jarek Poplawski" <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3659 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750747AbXKPQzz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2007 11:55:55 -0500
Content-class: urn:content-classes:message
In-Reply-To: <cccedfc60711160608j1ff89979uf7c1f122dd050adc@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jon Nelson wrote:

> The lspci is exactly as it was output. The dmesg is shortened only
> slightly. The kernel is the latest available for openSUSE 10.3. No MSI
> because this is an Athlon XP (read: 32bit, single core, regular old
> 33MHz, 32bit PCI).
> 

The lspci doesn't look correct to me either.  We don't have AGP
capability on these network cards.  Please provide:

lspci -vvxxx -s0:0:b.0

