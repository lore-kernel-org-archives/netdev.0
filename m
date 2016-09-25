From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v3 2/2] netfilter: Create revision 2 of xt_hashlimit to
 support higher pps rates
Date: Sun, 25 Sep 2016 13:35:01 +0200
Message-ID: <20160925113501.GD8331@salvia>
References: <20160922164344.GB20423@akamai.com>
 <alpine.LSU.2.20.1609221850530.27197@nerf40.vanv.qr>
 <57E42571.1060502@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jan Engelhardt <jengelh@inai.de>, kaber@trash.net,
        kadlec@blackhole.kfki.hu, johunt@akamai.com,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, pai.vishwain@gmail.com
To: Vishwanath Pai <vpai@akamai.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <57E42571.1060502@akamai.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 22, 2016 at 02:39:45PM -0400, Vishwanath Pai wrote:
> Thanks for pointing this out, I will reorder the fields to:
> 
> struct hashlimit_cfg2 {
> 	__u64 avg;    /* Average secs between packets * scale */
> 	__u64 burst;
> 	__u32 mode; /* bitmask of XT_HASHLIMIT_HASH_* */
> 
> This should fix the hole and avoid padding.

I have manually mangled this here, and applied, to get this change in
this in merge window.

I also have to revert the rename of XT_HASHLIMIT_SCALE to
XT_HASHLIMIT_SCALE_v1. This is exposed through uapi, this change would
break userspace.

Please, follow up in case of any fallout, thanks.
