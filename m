From: Hariprasad S <hariprasad@chelsio.com>
Subject: Re: [PATCH net-next 3/5] cxgb4: add dcb info node in debugfs
Date: Tue, 22 Dec 2015 17:11:32 +0530
Message-ID: <20151222113556.GA8043@hari-Latitude-E5550>
References: <1450682170-7106-1-git-send-email-hariprasad@chelsio.com>
 <1450682170-7106-4-git-send-email-hariprasad@chelsio.com>
 <CAJ3xEMjctGauyRjCKLV+wACkzDC5xF8J9khdhCm+YZXuEafU5Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, leedom@chelsio.com,
	nirranjan@chelsio.com, John Fastabend <john.r.fastabend@intel.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:28481 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752980AbbLVLlf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2015 06:41:35 -0500
Content-Disposition: inline
In-Reply-To: <CAJ3xEMjctGauyRjCKLV+wACkzDC5xF8J9khdhCm+YZXuEafU5Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 21, 2015 at 09:33:22 +0200, Or Gerlitz wrote:
> On Mon, Dec 21, 2015 at 9:16 AM, Hariprasad Shenai
> <hariprasad@chelsio.com> wrote:
> > Add new /sys/kernel/debug/cxgb4/*/dcb_info node to dump out
> > various Data Center Bridging information.
> 
> why? what's wrong with using the lldp tool for that purpose?

This is needed only for firmware managed DCBx. And when we are using
open LLDP instead of firmware managing DCBx, lldp tool can be used.

Hari
