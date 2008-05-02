From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] ethtool: command line support for lro
Date: Fri, 2 May 2008 15:34:58 +0100
Message-ID: <20080502143456.GL14219@solarflare.com>
References: <1204898997.4220.41.camel@moonstone.uk.level5networks.com> <20080307082538.1a674ae1@extreme> <1204909575.4220.71.camel@moonstone.uk.level5networks.com> <20080307134312.037e2cf6@extreme> <20080310180706.GF12660@solarflare.com> <20080417121119.GI21637@solarflare.com> <4818BC3C.8060601@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	Kieran Mansley <kmansley@solarflare.com>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:42700 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1760685AbYEBOf1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 10:35:27 -0400
Content-Disposition: inline
In-Reply-To: <4818BC3C.8060601@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kok, Auke wrote:
> I don't like the fact that you included the removal of a __KERNEL__ section in
> this patch - that should have been a separate patch IMHO :)
 
The changes to ethtool-copy.h can just as well be a separate patch, and can
be done mechanically with:

make -C <kernel-dir> INSTALL_HDR_PATH=$PWD/tmp headers_install
mv tmp/include/linux/ethtool.h ethtool-copy.h
rm -rf tmp

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
