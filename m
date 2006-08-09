From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [RFC: -mm patch] bcm43xx_main.c: remove 3 functions
Date: Wed, 9 Aug 2006 06:47:28 +0200
Message-ID: <200608090647.31890.mb@bu3sch.de>
References: <20060806030809.2cfb0b1e.akpm@osdl.org> <200608082032.38365.mb@bu3sch.de> <20060808194231.GQ3691@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Andrew Morton <akpm@osdl.org>, linville@tuxdriver.com,
	jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:34756
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1030469AbWHIErk
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 00:47:40 -0400
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20060808194231.GQ3691@stusta.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 08 August 2006 21:42, you wrote:
> And it seems to be your fault.  ;-)

Uh, oh. I'm trapped.

> commit 58e5528ee464d38040b9489e10033c9387a10d56
> Author: Michael Buesch <mb@bu3sch.de>
> Date:   Sat Jul 8 22:02:18 2006 +0200
> 
>     [PATCH] bcm43xx: init routine rewrite

Ah, I guessed it.
This was caused by some merge-race ;)
Will send a fix for this, soon.

-- 
Greetings Michael.
