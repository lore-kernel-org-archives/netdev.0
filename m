From: "Avuton Olrich" <avuton@gmail.com>
Subject: Re: Realtek RTL-8169 having receive errors
Date: Tue, 25 Mar 2008 16:21:26 -0700
Message-ID: <3aa654a40803251621n1cc1be84jcb2285ccde7d6883@mail.gmail.com>
References: <3aa654a40803241717g218f3d51pec42ecbb29835248@mail.gmail.com>
	 <20080325221050.GA2277@electric-eye.fr.zoreil.com>
	 <3aa654a40803251551ka5e6287uab79d99626e75ae2@mail.gmail.com>
	 <20080325225617.GB2277@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Francois Romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.183]:46843 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754637AbYCYXV1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2008 19:21:27 -0400
Received: by el-out-1112.google.com with SMTP id v27so2010460ele.17
        for <netdev@vger.kernel.org>; Tue, 25 Mar 2008 16:21:26 -0700 (PDT)
In-Reply-To: <20080325225617.GB2277@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 25, 2008 at 3:56 PM, Francois Romieu <romieu@fr.zoreil.com> wrote:
> Avuton Olrich <avuton@gmail.com> :
>  [...]
>
> > shapeshifter ~ # ethtool -s eth1 msglvl 255
>  > Cannot set new msglvl: Operation not supported
>
>  See ethtool -i eth1 and figure which ethX is relevant for your r8169 :o)

Well, that's interesting, prior to this I didn't realize how to find
out which driver controlled with ethX, so I was wrong, this is (yet
another) forcedeth issue. I took a 50/50 chance at it and came out
wrong. Thanks! :)

>  [...]
>
> > I can't even boot 2.6.23, so that's not doable. I will work on taking
>  > this machine down sometime this week, if it's possible and necessary.
>
>  Don't boot 2.6.23: compile its r8169 driver in a 2.6.22 tree.
>
>  Or simply revert d78ae2dcc2acebb9a1048278f47f762c069db75c with current
>  git (shot in the dark).

OK, I will try this if I can get a few hours of downtime for it.

Thanks again,
-- 
avuton
--
 Anyone who quotes me in their sig is an idiot. -- Rusty Russell.
