From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: IGB driver upgrade
Date: Tue, 29 Jun 2010 09:15:56 -0700
Message-ID: <4C2A1C3C.3040403@intel.com>
References: <AANLkTim6kfnr6yNeUXlLHOztB-qjyvj50D4p7nebqj9r@mail.gmail.com>	<AANLkTinUoQG4BWC4Q2UFDwGvAwYujlUXz6P-ZLkZozaQ@mail.gmail.com>	<4C293792.6070508@intel.com> <AANLkTim4zvNHegMqBnQG5jNGFU8nsaZbx83gv7FZuznu@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: sbs <gexlie@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:41879 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752537Ab0F2QP5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jun 2010 12:15:57 -0400
In-Reply-To: <AANLkTim4zvNHegMqBnQG5jNGFU8nsaZbx83gv7FZuznu@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sbs wrote:
> We're running 2.6.33.2 kernel version.
> I have compiled and installed 2.0.6 and 2.1.9 modules on two our servers.
> 
> Strange freezes usually appears in several (1 or 2) days.
> So I'll let you know when it happen and what module version will be
> responsible for that

Since the issue is being seen with the in-kernel driver and not the 
standalone module one other possibility is that this could be an issue 
that is specific to multi-queue.  You can test for this by setting the 
RSS parameter to 0 for the standalone module to enable multiple queues 
on the 2.2.9 driver.

One other thing you might want to try would be to test the latest 
release candidate kernel from kernel.org.  This would help to tell us if 
this is still an issue in the current kernel, or an issue that is 
present in just 2.6.33.

Thanks,

Alex
