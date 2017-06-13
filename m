From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net-next 08/10] bpf: nfp: Report bpf_prog ID during
 XDP_QUERY_PROG
Date: Mon, 12 Jun 2017 21:54:17 -0700
Message-ID: <20170613045411.2jxep4iotlsilfdt@dhcp-172-26-110-210.dhcp.thefacebook.com>
References: <20170613010025.2983342-1-kafai@fb.com>
 <20170613010025.2983342-9-kafai@fb.com>
 <20170612182842.3150789d@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:52734 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751915AbdFME4i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 00:56:38 -0400
Content-Disposition: inline
In-Reply-To: <20170612182842.3150789d@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 12, 2017 at 06:28:42PM -0700, Jakub Kicinski wrote:
> On Mon, 12 Jun 2017 18:00:23 -0700, Martin KaFai Lau wrote:
> > +	case XDP_QUERY_PROG: {
> > +		const struct bpf_prog *xdp_prog;
> > +
> > +		xdp_prog = READ_ONCE(nn->dp.xdp_prog);
> > +		if (xdp_prog)
> > +			xdp->prog_id = xdp_prog->aux->id;
> > +		else
> > +			xdp->prog_id = 0;
> >  		return 0;
> > +	}
> >  	default:
> >  		return -EINVAL;
> >  	}
>
> Why READ_ONCE?  I thought .ndo_xdp is always called under RTNL.
will remove in the next spin.
