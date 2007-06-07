From: Dave Jones <davej@redhat.com>
Subject: Re: warnings in git-wireless
Date: Wed, 6 Jun 2007 21:13:05 -0400
Message-ID: <20070607011305.GB24941@redhat.com>
References: <20070605020614.3f06b2ab.akpm@linux-foundation.org> <46671E5D.9070304@linux.intel.com> <20070606163534.6a6cffb7.akpm@linux-foundation.org> <4667364A.4040803@linux.intel.com> <20070606180421.c575f24b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Ketrenos <jketreno@linux.intel.com>,
	NetDev <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	linux-sparse@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:37374 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965285AbXFGBN3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jun 2007 21:13:29 -0400
Content-Disposition: inline
In-Reply-To: <20070606180421.c575f24b.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 06, 2007 at 06:04:21PM -0700, Andrew Morton wrote:

 > There _should_ be some #ifdeffable thing which is being passed to cpp when
 > we run sparse (but I'm not sure what it is).

#ifdef __CHECKER__

(See include/linux/compiler.h, this is how we implement __user & friends)

	Dave

-- 
http://www.codemonkey.org.uk
