From: Carl-Daniel Hailfinger <c-d.hailfinger.kernel.2004@gmx.net>
Subject: Re: [forcedeth] SET_NETDEV_DEV define
Date: Mon, 02 Feb 2004 02:18:29 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <401DA565.4050303@gmx.net>
References: <1075682822.401d9e06885a0@am.xs4all.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Alex de Landgraaf <alextreme@xs4all.nl>
In-Reply-To: <1075682822.401d9e06885a0@am.xs4all.nl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Alex,

Alex de Landgraaf wrote:
> Hey guys,
> 
> Nice work on the forcedeth patches! I've been waiting for a nvnet alternative
> for some time, and this seems to be it.
> 
> Anyway, in the forcedeth 2.4 v22 patch, it seems that forcedeth.c is missing the
> #define SET_NETDEV_DEV from v20. Adding it is relativly simple, just wanted to
> let you guys know that it doesn't compile on 2.4.23+ kernels (if you hadn't
> heard this earlier).

SET_NETDEV_DEV is in since 2.4.24-pre1 (but not in 2.4.24 due to
branching), so I decided to drop the macro. However it seems many people
use older kernels, so I will probably provide a patch that will also
compile for kernels older than current prepatches.

Since this has bitten a few users in the past week, I added a note to the
documents at http://www.hailfinger.org/carldani/linux/patches/forcedeth/

Basically, I wanted to reduce compatibility cruft to zero before
submitting the driver to Marcelo.


Thanks for the heads up,
Carl-Daniel
