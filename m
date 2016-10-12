From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH v6] net: ip, diag -- Add diag interface for raw sockets
Date: Wed, 12 Oct 2016 09:53:29 +0300
Message-ID: <20161012065329.GH1941@uranus.lan>
References: <20161006100055.GA1941@uranus.lan>
 <20161012.015022.2273537782016406180.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, jhs@mojatatu.com,
        dsa@cumulusnetworks.com, linux-kernel@vger.kernel.org,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, avagin@openvz.org, stephen@networkplumber.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161012.015022.2273537782016406180.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 12, 2016 at 01:50:22AM -0400, David Miller wrote:
> 
> Macros that look like function calls and are also lvalues tend to be
> troublesome.
> 
> I know what you're trying to achieve, you want a named way to access
> this so that the intent and semantics are clear.
> 
> But I'd rather you do something that provides a way by which normal
> struct member accesses do the job, and your earlier patches achieved
> this.

I can't rename the field, neither a can use union. The only acceptable
option I think is introduce inet_diag_v3 structure, which of course
will require the mode wide patching. If there no objections I could
try to implement it.
