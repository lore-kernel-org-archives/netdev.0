From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ethtool: Added a field fw dump_state
Date: Fri, 16 Mar 2012 14:22:42 -0700
Message-ID: <1331932962.19406.23.camel@edumazet-glaptop>
References: <CB88F67C.2A1CE%anirban.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Dept-NX Linux NIC Driver
	<Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Manish Chopra <manish.chopra@qlogic.com>
To: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:50420 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754267Ab2CPVWo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2012 17:22:44 -0400
Received: by pbcun15 with SMTP id un15so275570pbc.19
        for <netdev@vger.kernel.org>; Fri, 16 Mar 2012 14:22:43 -0700 (PDT)
In-Reply-To: <CB88F67C.2A1CE%anirban.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-03-16 at 14:10 -0700, Anirban Chakraborty wrote:
> 
> On 3/16/12 11:27 AM, "Ben Hutchings" <bhutchings@solarflare.com> wrote:
> 
> >On Fri, 2012-03-16 at 10:58 -0700, Anirban Chakraborty wrote:
> >> +
> >>  struct ethtool_dump {
> >>  	__u32	cmd;
> >>  	__u32	version;
> >>  	__u32	flag;
> >>  	__u32	len;
> >>  	__u8	data[0];
> >> +	__u8	dump_state;
> >
> >Don't be ridiculous.
> 
> Yeah I know, especially when there is a flag field already present there.
> The only
> reason, we considered for adding it is to keep the backward compatibility
> of scripts.
> Right now, the flag field sets/gets the dump level of fw. If we use it to
> control the
> dump state, then it would break the existing scripts, if there are any.
> 

You missed the point... data[0] must be the last element in the
structure.
