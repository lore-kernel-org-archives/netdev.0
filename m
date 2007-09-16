From: "L F" <lfabio.linux@gmail.com>
Subject: Re: e1000 driver and samba
Date: Sun, 16 Sep 2007 00:06:00 -0400
Message-ID: <780b6f780709152106q3d7f1042t72126c1be16ed1fd@mail.gmail.com>
References: <780b6f780709131904j41148fb4p827e87530b15d6e9@mail.gmail.com>
	 <46EAC25B.2060404@intel.com>
	 <780b6f780709141140l1fd586c9p2aa8efe6ed803d38@mail.gmail.com>
	 <46EAF644.1040006@intel.com> <46EC1A00.2000304@katalix.com>
	 <46EC2D5A.7080504@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "James Chapman" <jchapman@katalix.com>, netdev@vger.kernel.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.179]:62831 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750773AbXIPEGB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 00:06:01 -0400
Received: by wa-out-1112.google.com with SMTP id v27so1532823wah
        for <netdev@vger.kernel.org>; Sat, 15 Sep 2007 21:06:01 -0700 (PDT)
In-Reply-To: <46EC2D5A.7080504@intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> >>>      tx_deferred_ok: 486
>
> this one I wonder about, and might cause delays, I'll have to look up what it
> exactly could implicate though.
Please do and let me know. samba 3.0.26 helped, but the issue is still there.

> those are not "long frames" but the number of bytes the hardware counted in its
> "long" data type based byte counter.
Thank you for confirming that. It looks like it comes out to a little
over 32GB received... that sounds right.

> Auke

LF
