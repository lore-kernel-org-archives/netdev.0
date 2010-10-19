From: emin ak <eminak71@gmail.com>
Subject: Re: [Bugme-new] [Bug 19692] New: linux-2.6.36-rc5 crash with gianfar
 ethernet at full line rate traffic
Date: Tue, 19 Oct 2010 09:44:33 +0300
Message-ID: <AANLkTi=08Myz1=XOHkGJWTdyC8vK+y+zf0UQhjxUi=qC@mail.gmail.com>
References: <20101010103236.GA1919@del.dom.local>
	<20101015085853.GA8091@ff.dom.local>
	<AANLkTinAj=9-RqNA6xKc_5ONz2hPMRGM8uJ2Xy7XJVdr@mail.gmail.com>
	<20101016194815.GA1894@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Anton Vorontsov <avorontsov@mvista.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:63348 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756113Ab0JSGok (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Oct 2010 02:44:40 -0400
Received: by vws2 with SMTP id 2so1142729vws.19
        for <netdev@vger.kernel.org>; Mon, 18 Oct 2010 23:44:39 -0700 (PDT)
In-Reply-To: <20101016194815.GA1894@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jarek;
After 5 days and more then 20 billion packets passed without crash, it
seems that this patch is working for me, at least for crash type 2.
(For type 1, it only occured once and I can never reproduce this
again, but still trying. I think with this patch is also lowers the
risk for type 1.
For adding a new bug entry for skb_over_panic, before that I think I
must find a reliable way to make this type of crash reproducable,
otherwise I don't know how to test it if it solved or not.
Lastly, thanks a lot for your valuable help to overcome this problem
and also is there anything that I can do  for testing / commiting this
patch to mainline?

Thanks
Emin
