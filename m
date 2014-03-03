From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH net-next 0/4] ieee802154: clean up header handling
Date: Mon, 3 Mar 2014 14:59:48 +0100
Message-ID: <20140303135946.GA24286@omega>
References: <1393851547-27876-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net,
	davem@davemloft.net
To: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f180.google.com ([209.85.215.180]:39746 "EHLO
	mail-ea0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754008AbaCCN76 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 08:59:58 -0500
Received: by mail-ea0-f180.google.com with SMTP id m10so4493727eaj.39
        for <netdev@vger.kernel.org>; Mon, 03 Mar 2014 05:59:57 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1393851547-27876-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Phoebe,

On Mon, Mar 03, 2014 at 01:59:03PM +0100, Phoebe Buckheister wrote:
> This series of patches cleans up handling of 802.15.4 headers in ieee802154 and
> mac802154. Particularly, it introduces new functions to read and modify headers
> and removes the address fields in the skb cb block in favour of these
> functions. This set also fixes a bug that caused parts of an 802.15.4 header to
> be delivered to dgram sockets in userspace due to misparsed headers, and moves
> mac frame sequence number generation from upper layers into the netdev that
> actually handles them.
> 
besides the checkpatch issues, you can add a:
Tested-by: Alexander Aring <alex.aring@gmail.com>

on the whole serie.

- Alex
