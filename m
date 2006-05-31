From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 2/2] iWARP Core Changes.
Date: Wed, 31 May 2006 13:32:44 -0700
Message-ID: <adad5dux7df.fsf@cisco.com>
References: <20060531182650.3308.81538.stgit@stevo-desktop>
	<20060531182654.3308.41372.stgit@stevo-desktop>
	<adaodxeypfd.fsf@cisco.com> <1149107435.7469.7.camel@stevo-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mshefty@ichips.intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, openib-general@openib.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-3-in.cisco.com ([171.71.176.72]:40108 "EHLO
	sj-iport-3.cisco.com") by vger.kernel.org with ESMTP
	id S964821AbWEaUcq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 May 2006 16:32:46 -0400
To: Steve Wise <swise@opengridcomputing.com>
In-Reply-To: <1149107435.7469.7.camel@stevo-desktop> (Steve Wise's message of "Wed, 31 May 2006 15:30:35 -0500")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

    Steve> The function is needed by the iwcm module, so that's why we
    Steve> exported it.  I could change the name to rdma_copy_addr(),
    Steve> or make the function a static inline in a header file since
    Steve> its kinda small anyway...

It looks too big to inline to me, and I don't think it's on a fast
path anyway.  So I would export it.

 - R.
