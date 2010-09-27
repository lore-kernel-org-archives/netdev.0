From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v11 12/17] Add a kconfig entry and make entry for mp
 device.
Date: Mon, 27 Sep 2010 14:56:45 +0100
Message-ID: <1285595805.2263.13.camel@achroite.uk.solarflarecom.com>
References: <1285388855-27410-1-git-send-email-xiaohui.xin@intel.com>
	 <0eed02838e581f2ef2247be8e69bc34cdecce6b2.1285385607.git.xiaohui.xin@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mingo@elte.hu, davem@davemloft.net,
	herbert@gondor.hengli.com.au, jdike@linux.intel.com
To: xiaohui.xin@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:28276 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759386Ab0I0N4t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 09:56:49 -0400
In-Reply-To: <0eed02838e581f2ef2247be8e69bc34cdecce6b2.1285385607.git.xiaohui.xin@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is in the wrong position in the sequence.  It needs to be
applied after mpassthru.c is created, not before.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

