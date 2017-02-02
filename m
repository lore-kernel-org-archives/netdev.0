From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH v2] ethtool: do not vzalloc(0) on registers dump
Date: Thu, 2 Feb 2017 16:03:10 +0100
Message-ID: <20170202150309.GA16027@redhat.com>
References: <1486038730-9469-1-git-send-email-sgruszka@redhat.com>
 <20170202142717.GA22745@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Ben Hutchings <ben@decadent.org.uk>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56514 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751645AbdBBPH6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 2 Feb 2017 10:07:58 -0500
Content-Disposition: inline
In-Reply-To: <20170202142717.GA22745@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 02, 2017 at 09:27:18AM -0500, John W. Linville wrote:
> > -	regbuf = vzalloc(reglen);
> > -	if (reglen && !regbuf)
> > -		return -ENOMEM;
> > +	regbuf = NULL;
> 
> Any reason to prefer this over changing the declaration to include
> the assignment?
> 
> 	void *regbuf = NULL;

I've chosen this form to have initialization near the vzalloc() call,
after sanity checks, however I don't think it's better or worse over
declaration initialization.

Stanislaw
