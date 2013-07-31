From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] vxlan: fix rcu related warnings
Date: Tue, 30 Jul 2013 17:35:16 -0700
Message-ID: <20130730173516.3d536077@nehalam.linuxnetplumber.net>
References: <20130730131844.7d3f92de@nehalam.linuxnetplumber.net>
	<CALnjE+qx1L5p6CzFcd4nMTvWbxm-7_bz10wjbuUJdt12Q4Kqpg@mail.gmail.com>
	<20130730160245.4b7b84a1@nehalam.linuxnetplumber.net>
	<1375225499.10515.31.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Pravin Shelar <pshelar@nicira.com>,
	David Miller <davem@davemloft.net>,
	Thomas Richter <tmricht@linux.vnet.ibm.com>,
	Mike Rapoport <mike.rapoport@ravellosystems.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:52848 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757395Ab3GaAfU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 20:35:20 -0400
Received: by mail-pb0-f47.google.com with SMTP id rr13so81015pbb.20
        for <netdev@vger.kernel.org>; Tue, 30 Jul 2013 17:35:20 -0700 (PDT)
In-Reply-To: <1375225499.10515.31.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 30 Jul 2013 16:04:59 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Tue, 2013-07-30 at 16:02 -0700, Stephen Hemminger wrote:
> 
> > Which version of sparse? I don't see this with latest version.
> 
> Make sure you have CONFIG_SPARSE_RCU_POINTER=y
> 
> 

I have it enabled. And am using latest version from git.
