From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [PATCH 0/10] [IOAT] I/OAT patches repost
Date: Fri, 21 Apr 2006 19:13:57 +0200
Message-ID: <200604211913.57350.netdev@axxeo.de>
References: <Pine.LNX.4.44.0604201329300.22544-100000@isotope.jf.intel.com> <20060420213305.GK26746@pb15.lixom.net> <20060420.172742.132879746.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: olof@lixom.net, andrew.grover@intel.com, netdev@vger.kernel.org,
	Ingo Oeser <ioe-lkml@rameria.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:25543 "EHLO mail.axxeo.de")
	by vger.kernel.org with ESMTP id S1751334AbWDUROL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2006 13:14:11 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060420.172742.132879746.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> The first thing an application is going to do is touch that data.  So
> I think it's very important to prewarm the caches and the only
> straightforward way I know of to always warm up the correct cpu's
> caches is copy_to_user().

Hmm, what if the application is sth. like a MPEG demultiplexer?

There you don't like to look at everything and excplicitly 
ignore received data[1].

Yes, I know this is usually done with hardware demuxers and filters,
but the principle might apply to other applications as well, for which
no hardware solutions exist.


Regards

Ingo Oeser

[1] which you cannot ignore properly with Linux yet.
