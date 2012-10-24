From: Joe Perches <joe@perches.com>
Subject: Re: [BUG] checkpatch.pl with commit
 058806007450489bb8f457b275e5cb5c946320c1
Date: Wed, 24 Oct 2012 07:12:16 -0700
Message-ID: <1351087936.18179.9.camel@joe-AO722>
References: <1351076421.25066.14.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: jeffrey.t.kirsher@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1351076421.25066.14.camel@jtkirshe-mobl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-10-24 at 04:00 -0700, Jeff Kirsher wrote:
> With the recent commit to checkpatch.pl:
> 
> commit 058806007450489bb8f457b275e5cb5c946320c1
> Author: Joe Perches <joe@perches.com>
> Date:   Thu Oct 4 17:13:35 2012 -0700
> 
>     checkpatch: check networking specific block comment style
> 
> We are seeing false positive warnings.  Here is an example of the
> code the would generate a false warning:
> 
> #define foo	0x0000 /* foo comment */
> 
> checkpatch.pl generates a warnings that the */ should be on a separate
> line, which in this case is incorrect.

Sorry 'bout that.  I believe it's fixed by:
https://lkml.org/lkml/2012/10/14/267
