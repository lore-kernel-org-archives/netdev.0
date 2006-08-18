From: "Chris Leech" <christopher.leech@intel.com>
Subject: Re: [PATCH 1/7] [I/OAT] Push pending transactions to hardware more frequently
Date: Fri, 18 Aug 2006 08:11:47 -0700
Message-ID: <41b516cb0608180811m13a3d0bs90d1b9869ebaed59@mail.gmail.com>
References: <20060816005337.8634.70033.stgit@gitlost.site>
	 <20060818071157.GA7516@ucw.cz>
Reply-To: chris.leech@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.236]:19798 "EHLO
	wx-out-0506.google.com") by vger.kernel.org with ESMTP
	id S1030422AbWHRPLs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Aug 2006 11:11:48 -0400
Received: by wx-out-0506.google.com with SMTP id s14so705553wxc
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2006 08:11:47 -0700 (PDT)
To: "Pavel Machek" <pavel@ucw.cz>
In-Reply-To: <20060818071157.GA7516@ucw.cz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/18/06, Pavel Machek <pavel@ucw.cz> wrote:
>
> Huh, two version bumps for... ONE ONE-LINER :-).
>
> Could we get rid of embedded version? It helps no one.

Version numbers for drivers that can be built as modules are very
helpful for anyone wanting to upgrade a driver on top of a
distribution supported kernel.  If you always just use the latest
kernel source, you're right it doesn't help you.  But that's not
everyone.

This one skips two versions because I'm trying to sync up a 1.8
version tested internally with the 1.7+ upstream changes that's in the
kernel now.

I'll accept that the official policy is to not version modules when
MODULE_VERSION is removed :-)

- Chris
