From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] cxgb4: fix boolreturn.cocci warnings
Date: Wed, 25 Mar 2015 15:14:14 -0700
Message-ID: <1427321654.15849.3.camel@perches.com>
References: <201503260524.AdqSbov9%fengguang.wu@intel.com>
	 <20150325215525.GA26868@athens>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Varun Prakash <varun@chelsio.com>, kbuild-all@01.org,
	Hariprasad S <hariprasad@chelsio.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: kbuild test robot <fengguang.wu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0117.hostedemail.com ([216.40.44.117]:58607 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752541AbbCYWOS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 18:14:18 -0400
In-Reply-To: <20150325215525.GA26868@athens>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-03-26 at 05:55 +0800, kbuild test robot wrote:
> drivers/net/ethernet/chelsio/cxgb4/cxgb4_fcoe.c:49:9-10: WARNING: return of 0/1 in function 'cxgb_fcoe_sof_eof_supported' with return type bool

Hey Fengguang.

There are so many of these that could be fixed.

Did you establish a queue to ration them out slowly
or do you just do them every once in awhile?

cheers, Joe
