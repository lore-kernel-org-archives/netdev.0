From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [RFC PATCH - diffstat only] include/net: Remove extern from
 function prototypes
Date: Thu, 25 Jul 2013 01:27:49 +0000 (UTC)
Message-ID: <kspuuk$k2v$1@ger.gmane.org>
References: <1374602291.3387.17.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 23 Jul 2013 at 17:58 GMT, Joe Perches <joe@perches.com> wrote:
> Function prototypes don't need to be declared
> extern in .h files.  It's assumed by the compiler
> and is as unnecessary as using auto is when
> declaring automatic/local variables in a block.
>

Since we all know this, why bother it? Having "extern" doesn't harm
readability, instead it probably helps.

...
>
> I believe it makes grepping for extern useful as
> all the matches are actual variables and structs.
>

You need a semantic tool.
