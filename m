From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6] net: ip, diag -- Add diag interface for raw sockets
Date: Wed, 12 Oct 2016 01:50:22 -0400 (EDT)
Message-ID: <20161012.015022.2273537782016406180.davem@davemloft.net>
References: <20161006100055.GA1941@uranus.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, jhs@mojatatu.com,
        dsa@cumulusnetworks.com, linux-kernel@vger.kernel.org,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, avagin@openvz.org, stephen@networkplumber.org
To: gorcunov@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161006100055.GA1941@uranus.lan>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Cyrill Gorcunov <gorcunov@gmail.com>
Date: Thu, 6 Oct 2016 13:00:55 +0300

> v6:
>  - use sdiag_raw_protocol() helper which will access @pad
>    structure used for raw sockets protocol specification:
>    we can't simply rename this member without breaking uapi.

Macros that look like function calls and are also lvalues tend to be
troublesome.

I know what you're trying to achieve, you want a named way to access
this so that the intent and semantics are clear.

But I'd rather you do something that provides a way by which normal
struct member accesses do the job, and your earlier patches achieved
this.
