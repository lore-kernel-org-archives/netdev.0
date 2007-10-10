From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [RFC PATCH net-2.6.24 0/5]: TCP sacktag cache usage recoded
Date: Wed, 10 Oct 2007 13:26:05 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0710101300221.3767@kivilampi-30.cs.helsinki.fi>
References: <11906297271684-git-send-email-ilpo.jarvinen@helsinki.fi>
 <20071010.025829.106434530.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-1476532593-1192011965=:3767"
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	sangtae.ha@gmail.com, virtualphtn@gmail.com,
	Baruch Even <baruch@ev-en.org>, Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:54688 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752099AbXJJK0J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 06:26:09 -0400
In-Reply-To: <20071010.025829.106434530.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1476532593-1192011965=:3767
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Wed, 10 Oct 2007, David Miller wrote:

> From: "Ilpo_Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Mon, 24 Sep 2007 13:28:42 +0300
> 
> > After couple of wrong-wayed before/after()s and one infinite
> > loopy version, here's the current trial version of a sacktag  
> > cache usage recode....
> > 
> > Two first patches come from tcp-2.6 (rebased and rotated).
> > This series apply cleanly only on top of the other three patch
> > series I posted earlier today. The last debug patch provides
> > some statistics for those interested enough.
> > 
> > Dave, please DO NOT apply! ...Some thoughts could be nice
> > though :-).
> 
> Ilpo, I have not forgotten about this patch set.
> 
> It is something I plan to look over after the madness of merging
> net-2.6.24 to Linus is complete.

Thanks, there's probably going to be some trouble though, I'd bet it 
doesn't anymore apply cleanly to net-2.6.23 HEAD because of something else 
that got applied (don't remember exactly but I guess that highest_sack 
reno fix did that).

I try to get them resent soon but currently my thoughts are in solving 
DSACK ignored bug (and doing the associated cleanups) which again will 
cause those code move conflicts to reoccur. Therefore I'd love to postpone 
the rebase a bit... Hmm, SACK code is under such flux currently that I'll 
have to deal conflicts almost daily due to overlapping ideas...


-- 
 i.
---696243703-1476532593-1192011965=:3767--
