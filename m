From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [PATCH 1/2] atl1: fix resume
Date: Thu, 16 Sep 2010 14:13:18 -0700
Message-ID: <20100916211318.GA29619@kroah.com>
References: <AANLkTincBZrpHch0rv60YRXW2g=cqgO9vueAafcs=+RQ@mail.gmail.com>
 <1284665387-10289-2-git-send-email-kronos.it@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jcliburn@gmail.com, chris.snook@gmail.com,
	jie.yang@atheros.com, atl1-devel@lists.sourceforge.net,
	stable@kernel.org
To: Luca Tettamanti <kronos.it@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:59787 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753515Ab0IPVN6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Sep 2010 17:13:58 -0400
Content-Disposition: inline
In-Reply-To: <1284665387-10289-2-git-send-email-kronos.it@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 16, 2010 at 09:29:46PM +0200, Luca Tettamanti wrote:
> adapter->cmb.cmb is initialized when the device is opened and freed when
> it's closed. Accessing it unconditionally during resume results either
> in a crash (NULL pointer dereference, when the interface has not been
> opened yet) or data corruption (when the interface has been used and
> brought down adapter->cmb.cmb points to a deallocated memory area).
> 
> Cc: stable@kernel.org
> ---

You do realize you need to sign-off on a patch you create, right?

thanks,

greg k-h
