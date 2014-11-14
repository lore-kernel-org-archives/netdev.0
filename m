From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Subject: RE: [PATCH] carl9170: Convert byte_rev_table uses to bitrev8
Date: Fri, 14 Nov 2014 13:37:39 +0800
Message-ID: <35FD53F367049845BC99AC72306C23D103E010D1829E@CNBJMBX05.corpusers.net>
References: <35FD53F367049845BC99AC72306C23D103E010D1829D@CNBJMBX05.corpusers.net>
 <1415943164.5912.4.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "'chunkeey@googlemail.com'" <chunkeey@googlemail.com>,
	"'linville@tuxdriver.com'" <linville@tuxdriver.com>,
	"'linux-wireless@vger.kernel.org'" <linux-wireless@vger.kernel.org>,
	"'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	"'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>
To: 'Joe Perches' <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415943164.5912.4.camel@perches.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: Joe Perches [mailto:joe@perches.com]
> Sent: Friday, November 14, 2014 1:33 PM
> To: Wang, Yalin
> Cc: 'chunkeey@googlemail.com'; 'linville@tuxdriver.com'; 'linux-
> wireless@vger.kernel.org'; 'netdev@vger.kernel.org'; 'linux-
> kernel@vger.kernel.org'
> Subject: Re: [PATCH] carl9170: Convert byte_rev_table uses to bitrev8
> 
> On Fri, 2014-11-14 at 13:16 +0800, Wang, Yalin wrote:
> > Use the inline function instead of directly indexing the array.
> >
> > This allows some architectures with hardware instructions for bit
> > reversals to eliminate the array.
> 
> This one is already in -next
> 
> commit 7a1283d8f5298437a454ec477384dcd9f9f88bac
> Author: Joe Perches <joe@perches.com>
> Date:   Tue Oct 28 14:18:58 2014 -0700
> 
>     carl9170: Convert byte_rev_table uses to bitrev8
> 
>     Use the inline function instead of directly indexing the array.
> 
>     This allows some architectures with hardware instructions
>     for bit reversals to eliminate the array.
> 
>     Signed-off-by: Joe Perches <joe@perches.com>
>     Signed-off-by: John W. Linville <linville@tuxdriver.com>
> 
Got it ,
So I need wait for your another patch to be accepted.

Thanks!
