From: Greg Rose <gregory.v.rose@intel.com>
Subject: Re: New commands to configure IOV features
Date: Mon, 7 May 2012 08:16:34 -0700
Message-ID: <20120507081634.000003f8.gregory.v.rose@intel.com>
References: <4FA7AF62.8000405@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:27457 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756287Ab2EGPQi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 May 2012 11:16:38 -0400
In-Reply-To: <4FA7AF62.8000405@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 7 May 2012 14:17:54 +0300
Yuval Mintz <yuvalmin@broadcom.com> wrote:

> I've tried to figure out if there was a standard interface
> (ethtool/iproute) through which a user could configure the number
> of vfs in his system.
> 
> I've seen the RFC suggested in
> http://markmail.org/thread/qblfcv7zbxsxp7q6, and
> http://markmail.org/thread/fw54dcppmxuxoe6n, but failed to see any
> later references to it (commits or further discussion on this topic).
> 
> How exactly are things standing with these RFCs? Were they abandoned?

The only way to configure the number of VFs continues to be through the
max_vfs module parameter.  I've got a patch to do it through ethtool
sitting on the back burner but due to other requirements of my day job
I've not been able to work on it since last fall.

- Greg

> 
> Thanks,
> Yuval
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
