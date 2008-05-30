From: "Adam Langley" <agl@imperialviolet.org>
Subject: Re: [PATCH] Fix corrupt TCP packets when options space overflows with MD5SIG enabled
Date: Fri, 30 May 2008 12:11:44 -0700
Message-ID: <396556a20805301211g7dd98ae7m185a356e611e81aa@mail.gmail.com>
References: <396556a20805301140x586093e5o92d44e38f7c2869a@mail.gmail.com>
	 <20080530190218.GD1743@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: "Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.180]:29608 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751936AbYE3TLp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2008 15:11:45 -0400
Received: by py-out-1112.google.com with SMTP id p76so53360pyb.10
        for <netdev@vger.kernel.org>; Fri, 30 May 2008 12:11:45 -0700 (PDT)
In-Reply-To: <20080530190218.GD1743@solarflare.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 30, 2008 at 12:02 PM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> Putting an #ifdef..#endif in the middle of an if () is a bit nasty.  Why not
> define md5 and set it to 0 if CONFIG_TCP_MD5SIG is not set?  The compiler
> should be able to optimise it away if it's always initialised to 0.

That's a good point, thanks. Followup patch in a second...



AGL

-- 
Adam Langley agl@imperialviolet.org http://www.imperialviolet.org
