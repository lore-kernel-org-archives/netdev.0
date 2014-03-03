From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [Linux-zigbee-devel] [PATCH 4/4] ieee802154: remove seq member
 of mac_cb
Date: Mon, 3 Mar 2014 16:40:16 +0100
Message-ID: <20140303154015.GA2003@x61s.Speedport_W_921V_1_24_000>
References: <1393851547-27876-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
 <1393851547-27876-5-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
 <20140303140601.GB24286@omega>
 <20140303151219.42ed91f4@zoidberg>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-zigbee-devel@lists.sourceforge.net
To: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:51776 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754032AbaCCP2L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 10:28:11 -0500
Received: by mail-ee0-f54.google.com with SMTP id d49so850053eek.27
        for <netdev@vger.kernel.org>; Mon, 03 Mar 2014 07:28:10 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20140303151219.42ed91f4@zoidberg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 03, 2014 at 03:12:19PM +0100, Phoebe Buckheister wrote:
> > On a fragmented packet 6lowpan calls dev_hard_header once, then many
> > times lowpan_fragment_xmit, depending on the number of fragments which
> > is needed.
> 
> To me, the obvious answer would be "just don't do that". Each fragment
> is a distinct packet, so it should not reuse a header that was created
> for another packet in the first place.
> 
mhh, then the best solution would be to drop the copy of the mac header
and generate it there.

- Alex
