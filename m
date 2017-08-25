From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [RFC PATCH] net: limit maximum number of packets to mark with
 xmit_more
Date: Fri, 25 Aug 2017 15:34:18 -0400
Message-ID: <20170825153418.53864810@cakuba>
References: <20170825152449.29790-1-jacob.e.keller@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jacob Keller <jacob.e.keller@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.12]:13419 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758345AbdHYTeZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 25 Aug 2017 15:34:25 -0400
In-Reply-To: <20170825152449.29790-1-jacob.e.keller@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 25 Aug 2017 08:24:49 -0700, Jacob Keller wrote:
> Under some circumstances, such as with many stacked devices, it is
> possible that dev_hard_start_xmit will bundle many packets together, and
> mark them all with xmit_more.

Excuse my ignorance but what are those stacked devices?  Could they
perhaps be fixed somehow?  My intuition was that long xmit_more
sequences can only happen if NIC and/or BQL are back pressuring, and
therefore we shouldn't be seeing a long xmit_more "train" arriving at
an empty device ring...
