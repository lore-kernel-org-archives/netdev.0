From: David Miller <davem@davemloft.net>
Subject: Re: size of data_segs_[in|out] and segs_[in|out]
Date: Tue, 09 Aug 2016 12:04:58 -0700 (PDT)
Message-ID: <20160809.120458.792987014914899369.davem@davemloft.net>
References: <797392fa-8d87-f45b-69b2-fdd096e1229c@psc.edu>
	<20160808.160245.2063863440275871547.davem@davemloft.net>
	<e0a3f13a-f3cc-8455-8e7d-9c604f8ef4fb@psc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: rapier@psc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:32983 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751774AbcHITFF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 15:05:05 -0400
Received: by mail-pf0-f169.google.com with SMTP id y134so7714454pfg.0
        for <netdev@vger.kernel.org>; Tue, 09 Aug 2016 12:05:04 -0700 (PDT)
In-Reply-To: <e0a3f13a-f3cc-8455-8e7d-9c604f8ef4fb@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: rapier <rapier@psc.edu>
Date: Tue, 9 Aug 2016 13:17:59 -0400

> I cannot deny that would be a problem but conversely, those
> applications are currently in a position where they may be depending
> on inaccurate data. I'm not advocating breaking things for the sake of
> breaking things but my feeling is that this will eventually need to be
> addressed. Since the segs datastructure is a relatively recent
> addition it might make sense to make that change now before it's even
> more baked in to other applications.

Changing the size or position of these data structure members is
simply not an option.  It is locked into stone, and a permanent
ABI which we cannot change.

Please stop discussing as if changing this is a possibility.

You need to find another solution to the problem, or advocate a
user side solution (periodic polling).
