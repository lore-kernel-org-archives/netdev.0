From: Alex Gartrell <alexgartrell@gmail.com>
Subject: Re: [PATCH,v2 net-next] ipvs: skb_orphan in case of forwarding
Date: Sun, 5 Jul 2015 21:14:38 -0700
Message-ID: <CALCkm3d4Xqq+eWryejKhi84rM_fS4QRyu8Fn_Z7RHZv+zbv3_Q@mail.gmail.com>
References: <1436131706-1559824-1-git-send-email-agartrell@fb.com>
 <alpine.LFD.2.11.1507060105470.12815@ja.home.ssi.bg> <CALCkm3eyEbHpzfF1zk0OUnGaSf51=r9DmZs_2Xq4fTtOed3nNQ@mail.gmail.com>
 <20150706035019.GA9155@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Julian Anastasov <ja@ssi.bg>, Alex Gartrell <agartrell@fb.com>,
	lvs-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	kernel-team <kernel-team@fb.com>
To: Simon Horman <horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20150706035019.GA9155@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jul 5, 2015 at 8:50 PM, Simon Horman <horms@verge.net.au> wrote:
> Is it possible to get a 'Fixes:' tag?

I suppose it'd be appropriate to say

Fixes: 41063e9dd119 ("ipv4: Early TCP socket demux.")

As that is what introduces tcp early_demux, but that's just a guess as
I haven't bisected it (not even sure my test would run on that code
base).

-- 
Alex Gartrell <agartrell@fb.com>
