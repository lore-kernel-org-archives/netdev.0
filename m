From: David Miller <davem@davemloft.net>
Subject: Re: size of data_segs_[in|out] and segs_[in|out]
Date: Mon, 08 Aug 2016 16:02:45 -0700 (PDT)
Message-ID: <20160808.160245.2063863440275871547.davem@davemloft.net>
References: <797392fa-8d87-f45b-69b2-fdd096e1229c@psc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: rapier@psc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:34338 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751542AbcHHXCr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2016 19:02:47 -0400
Received: by mail-pf0-f181.google.com with SMTP id p64so123498711pfb.1
        for <netdev@vger.kernel.org>; Mon, 08 Aug 2016 16:02:47 -0700 (PDT)
In-Reply-To: <797392fa-8d87-f45b-69b2-fdd096e1229c@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: rapier <rapier@psc.edu>
Date: Mon, 8 Aug 2016 18:02:29 -0400

> As such, would it be feasible to define these instruments as 64bit
> instead of 32bit? If so, a cursory look at the code seems to indicate
> that this would only require a change in the header files.

It would break every application looking at these datastructures
right now.
