From: Per Hedeland <per@hedeland.org>
Subject: Re: [Bonding-devel] [PATCH] [bonding 2.4] Add balance-xor-ip bonding mode
Date: Thu, 8 Jan 2004 17:43:58 +0100 (CET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401081643.i08GhwRP059382@pluto.hedeland.org>
References: <200401081733.44744.amir.noam@intel.com>
Cc: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: amir.noam@intel.com
In-Reply-To: <200401081733.44744.amir.noam@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Amir Noam <amir.noam@intel.com> wrote:

>Please use u32 instead of __u32.

OK.

>hmm...
>
>I don't like this. The reason we give different tx function pointers
>to dev->hard_start_xmit in different bonding mode is to make the tx
>path as fast as possible. Otherwise we might as well use a single tx
>function that chooses its exact operation based on the bonding mode.
>
>It might be better to have some code duplication if it results in
>faster tx, but I'm not sure what's the optimal solution in this case.

Well, I don't really have an opinion since I don't have a good idea
about the cost of a function call relative to "everything else" that is
happening here. I don't see a way to do "limited" duplication without
using function calls though, but I'm quite happy to make it two entirely
separate functions for MAC vs IP. Please advise.

--Per Hedeland
per@hedeland.org
