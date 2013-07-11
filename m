From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v2] gso: Update tunnel segmentation to support Tx
 checksum offload
Date: Wed, 10 Jul 2013 19:37:03 -0700
Message-ID: <1373510223.4600.36.camel@edumazet-glaptop>
References: <20130711000015.13134.17801.stgit@ahduyck-hc1.jf.intel.com>
	  <1373503334.4600.27.camel@edumazet-glaptop>
	 <1373507037.4600.34.camel@edumazet-glaptop> <51DE18E1.304@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dmitry Kravkov <dmitry@broadcom.com>, netdev@vger.kernel.org,
	stephen@networkplumber.org, pshelar@nicira.com,
	joseph.gasparakis@intel.com, jesse@nicira.com,
	Eilon Greenstein <eilong@broadcom.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:55548 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755217Ab3GKChF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jul 2013 22:37:05 -0400
Received: by mail-pd0-f182.google.com with SMTP id r10so6983232pdi.13
        for <netdev@vger.kernel.org>; Wed, 10 Jul 2013 19:37:04 -0700 (PDT)
In-Reply-To: <51DE18E1.304@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-07-10 at 19:30 -0700, Alexander Duyck wrote:

> 
> It was my understanding that the code for enabling TSO for encapsulated
> frames was good as Joseph has been working on it and testing it for
> i40e.  I'm assuming if you turn off TSO then the GSO and Tx checksum are
> working correctly?  I just want to make sure the issue you are seeing
> isn't in any way related to my patch.

Disabling TSO is solving the issue, and your patch solves the csum
performance issue.

I would like to fully understand the problems before acknowledging your
patch, if you do not mind ;)
