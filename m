From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] vxlan: fix rcu related warnings
Date: Tue, 30 Jul 2013 16:04:59 -0700
Message-ID: <1375225499.10515.31.camel@edumazet-glaptop>
References: <20130730131844.7d3f92de@nehalam.linuxnetplumber.net>
	 <CALnjE+qx1L5p6CzFcd4nMTvWbxm-7_bz10wjbuUJdt12Q4Kqpg@mail.gmail.com>
	 <20130730160245.4b7b84a1@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Pravin Shelar <pshelar@nicira.com>,
	David Miller <davem@davemloft.net>,
	Thomas Richter <tmricht@linux.vnet.ibm.com>,
	Mike Rapoport <mike.rapoport@ravellosystems.com>,
	netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:33922 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753487Ab3G3XFB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 19:05:01 -0400
Received: by mail-pa0-f54.google.com with SMTP id kx1so123517pab.13
        for <netdev@vger.kernel.org>; Tue, 30 Jul 2013 16:05:01 -0700 (PDT)
In-Reply-To: <20130730160245.4b7b84a1@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-07-30 at 16:02 -0700, Stephen Hemminger wrote:

> Which version of sparse? I don't see this with latest version.

Make sure you have CONFIG_SPARSE_RCU_POINTER=y
