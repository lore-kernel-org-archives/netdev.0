From: "=?ISO-8859-1?Q?Jochen_Vo=DF?=" <jochen.voss@googlemail.com>
Subject: Re: [PATCH] e1000: fix stack size
Date: Thu, 28 Aug 2008 11:17:19 +0100
Message-ID: <ef1cd66f0808280317r72f98402x5f4c23bf4aaf100d@mail.gmail.com>
References: <20080827081446.9269.19136.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net,
	akpm@linux-foundation.org,
	"Linus Torvalds" <torvalds@linux-foundation.org>
To: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.30]:60644 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751266AbYH1KRU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2008 06:17:20 -0400
Received: by yx-out-2324.google.com with SMTP id 8so168009yxm.1
        for <netdev@vger.kernel.org>; Thu, 28 Aug 2008 03:17:19 -0700 (PDT)
In-Reply-To: <20080827081446.9269.19136.stgit@jtkirshe-mobile.jf.intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

2008/8/27 Jeff Kirsher <jeffrey.t.kirsher@intel.com>:
> From: Linus Torvalds <torvalds@linux-foundation.org>
>
> Here's the patch. It shrinks the stack from 1152 bytes to 192 bytes (the
> first version, that only did the e1000_option part, got it down to 600
> bytes). About half comes from not using multiple "e1000_option"
> structures, the other half comes from turning the "e1000_opt_list[]"
> arrays into "static const" instead, so that gcc doesn't copy them onto the
> stack.
>
> Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
> Reveiewed-by: Auke Kok <auke-jan.h.kok@intel.com>
  ^^^^^^^^^^^^^^
  typo here

> Tested-by: Emil Tantilov <emil.s.tantilov@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

I hope this helps,
Jochen
-- 
http://seehuhn.de/
