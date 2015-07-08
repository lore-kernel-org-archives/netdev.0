From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH,v2 net-next] ipvs: skb_orphan in case of forwarding
Date: Wed, 08 Jul 2015 23:17:52 +0200
Message-ID: <1436390272.24939.10.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1436131706-1559824-1-git-send-email-agartrell@fb.com>
	 <alpine.LFD.2.11.1507060105470.12815@ja.home.ssi.bg>
	 <CALCkm3eyEbHpzfF1zk0OUnGaSf51=r9DmZs_2Xq4fTtOed3nNQ@mail.gmail.com>
	 <20150706035019.GA9155@verge.net.au>
	 <CALCkm3d4Xqq+eWryejKhi84rM_fS4QRyu8Fn_Z7RHZv+zbv3_Q@mail.gmail.com>
	 <20150708013355.GE28100@verge.net.au>
	 <CALCkm3f0NTwUugb=sWVWQ2bJdecmZR_LFHocznuVR8fKRtRLkQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>,
	Alex Gartrell <agartrell@fb.com>, lvs-devel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>, kernel-team <kernel-team@fb.com>
To: Alex Gartrell <alexgartrell@gmail.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <CALCkm3f0NTwUugb=sWVWQ2bJdecmZR_LFHocznuVR8fKRtRLkQ@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-07-08 at 13:56 -0700, Alex Gartrell wrote:
> On Tue, Jul 7, 2015 at 6:33 PM, Simon Horman <horms@verge.net.au> wrote:
> 
> > Is there any possibility you could investigate which stable trees are
> > effected by this bug?
> 
> Well this was certainly a problem in 3.10 (we had our own hacky
> solution at the time) and every kernel since then would have also had
> this problem.  I'm pretty sure this isn't a problem in 3.4 or before.
> 

early demux was added in 3.6

Fixes: 41063e9dd119 ("ipv4: Early TCP socket demux.")

