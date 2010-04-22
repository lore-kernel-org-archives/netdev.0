From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: Re: [patch] wimax: wimax_msg_alloc() returns ERR_PTR not null
Date: Thu, 22 Apr 2010 14:59:56 -0700
Message-ID: <1271973596.2867.3.camel@localhost.localdomain>
References: <20100422094632.GM29647@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	=?ISO-8859-1?Q?Andr=E9?= Goddard Rosa <andre.goddard@gmail.com>,
	kernel-janitors@vger.kernel.org, wimax@linuxwimax.org,
	linux-wimax@intel.com
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga10.intel.com ([192.55.52.92]:57467 "EHLO
	fmsmga102.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752095Ab0DVWDk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 18:03:40 -0400
In-Reply-To: <20100422094632.GM29647@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-04-22 at 11:46 +0200, Dan Carpenter wrote: 
> wimax_msg_alloc() returns an ERR_PTR and not null.  I changed it to test
> for ERR_PTR instead of null.  I also added a check in front of the
> kfree() because kfree() can handle null but not ERR_PTR.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Good catch thank you!

Will merge ASAP in preparation for the next push


