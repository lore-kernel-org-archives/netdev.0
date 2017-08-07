From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next 02/13] nfp: change bpf verifier hooks to
 match new verifier data structures
Date: Sun, 06 Aug 2017 21:01:35 -0700 (PDT)
Message-ID: <20170806.210135.446661763275623611.davem@davemloft.net>
References: <22441d84-0a11-5c00-2d2a-25e7dbafa6c2@solarflare.com>
        <3d69276f-9f16-0c1a-4596-5c909abe08fc@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, ast@fb.com, daniel@iogearbox.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        iovisor-dev@lists.iovisor.org
To: ecree@solarflare.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3d69276f-9f16-0c1a-4596-5c909abe08fc@solarflare.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Edward Cree <ecree@solarflare.com>
Date: Thu, 3 Aug 2017 17:11:34 +0100

> Signed-off-by: Edward Cree <ecree@solarflare.com>

Sorry, this doesn't work.

The entire source tree must compile properly after each patch in the
patch series.

So if you change a datastructure, you have to update all of the users
in that patch to keep everything compiling and working.
