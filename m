From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: i40e: Add code to handle FD table full condition
Date: Mon, 7 Apr 2014 21:31:49 -0700
Message-ID: <20140407213149.00005d1b@unknown>
References: <20140403052019.CFC67661245@gitolite.kernel.org>
	<20140404145930.GA20434@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <anjali.singhai@intel.com>,
	<jeffrey.t.kirsher@intel.com>, jesse.brandeburg@intel.com
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:16142 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750708AbaDHEcT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Apr 2014 00:32:19 -0400
In-Reply-To: <20140404145930.GA20434@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 4 Apr 2014 10:59:30 -0400
Dave Jones <davej@redhat.com> wrote:
>  > +			/* Turn off ATR first */
>  > +			if (pf->flags | I40E_FLAG_FD_ATR_ENABLED) {
> 
> This condition is always true.

Ouch, that is a nice catch Dave!  We will submit a fix shortly.  I'll
cook something up now and push it to JeffK for a quick check before it
gets upstream.

Thanks!
Jesse
