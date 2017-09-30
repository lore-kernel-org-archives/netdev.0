From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net-next 2/5] bpf: Add map_name to bpf_map_info
Date: Fri, 29 Sep 2017 19:52:21 -0700
Message-ID: <20170929195221.732aab55@cakuba>
References: <20170927213756.1254938-1-kafai@fb.com>
        <20170927213756.1254938-3-kafai@fb.com>
        <20170929190746.322df52d@cakuba>
        <20170930023518.bmc6dbpnz27wunod@kafai-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.9]:14412 "EHLO mx3.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752649AbdI3Cwa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 29 Sep 2017 22:52:30 -0400
In-Reply-To: <20170930023518.bmc6dbpnz27wunod@kafai-mbp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 29 Sep 2017 19:35:18 -0700, Martin KaFai Lau wrote:
> On Sat, Sep 30, 2017 at 02:07:46AM +0000, Jakub Kicinski wrote:
> > Hi Martin!
> > 
> > On Wed, 27 Sep 2017 14:37:53 -0700, Martin KaFai Lau wrote:  
> > > diff --git a/include/linux/bpf.h b/include/linux/bpf.h
> > > index 33ccc474fb04..252f4bc9eb25 100644
> > > --- a/include/linux/bpf.h
> > > +++ b/include/linux/bpf.h
> > > @@ -56,6 +56,7 @@ struct bpf_map {
> > >  	struct work_struct work;
> > >  	atomic_t usercnt;
> > >  	struct bpf_map *inner_map_meta;
> > > +	u8 name[BPF_OBJ_NAME_LEN];  
> > 
> > Any reason not to use plain char?  I was looking at adding names to
> > bpftool and:  
> Happy to have early user :)

The newly exposed info is so useful I couldn't resist :)

> It was mostly due to my early idea on treating the name as
> a blob without much char checking, which was then trashed
> but did not reflect that here.
> 
> I will make a followup patch later.

Awesome, thanks!
