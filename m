From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/7] NetLabel: documentation
Date: Fri, 28 Jul 2006 00:51:04 -0700 (PDT)
Message-ID: <20060728.005104.78711481.davem@davemloft.net>
References: <20060717155224.060020000@hp.com>
	<20060717155821.600856000@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, sds@epoch.ncsc.mil,
	jmorris@redhat.com, pratt@argus-systems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:42912
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030224AbWG1HvU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jul 2006 03:51:20 -0400
To: paul.moore@hp.com
In-Reply-To: <20060717155821.600856000@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: paul.moore@hp.com
Date: Mon, 17 Jul 2006 11:52:25 -0400

> +CIPSOv4 Variables:
> +
> +cipso_cache_enable - BOOLEAN
 ...
> +cipso_cache_bucket_size - INTEGER
 ...
> +cipso_rbm_optfmt - BOOLEAN
 ...
> +cipso_rbm_structvalid - BOOLEAN
 ...

We need some more information for these entries.

First, list the default value these sysctls will have.
This is consistent with other entries in this file.  If
there is a compelling argument to support the default
value, please mention it.

Second, cipso_cache_bucket_size is still opaque, there is
nothing in the description with describes the units this
value is specified in, nor in fact what it really controls.
Does it say how deep the hash chains of the hash table are
allowed to grow to?  Otherwise, what does it control and what
are the consequences of using different values?

