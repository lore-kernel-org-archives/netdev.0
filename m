From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [net-next 08/14] igb: Combine post-processing of skb into a
 single function
Date: Fri, 19 Oct 2012 16:32:49 +0200
Message-ID: <1350657169.2293.679.camel@edumazet-glaptop>
References: <1350647114-6768-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1350647114-6768-9-git-send-email-jeffrey.t.kirsher@intel.com>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B7058@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:39901 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964872Ab2JSOcz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2012 10:32:55 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so261720bkc.19
        for <netdev@vger.kernel.org>; Fri, 19 Oct 2012 07:32:53 -0700 (PDT)
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7058@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-10-19 at 14:49 +0100, David Laight wrote:
> > From: Alexander Duyck <alexander.h.duyck@intel.com>
> > 
> > This change is meant to just clean-up a number of function calls that were
> > made at the end of the Rx clean-up path by combining them into a single
> > function call.
> 
> Since the functions are static and only called once they
> are prime candidates for inlining.
> This might happen anyway (depending on the gcc version
> and the direction the wind is blowing in).
> 
> Marking them with __attribute__((always_inline)) might
> be needed to get them actually inlined.
> 
> That would maintain the logical separation.

vi +712 Documentation/CodingStyle
