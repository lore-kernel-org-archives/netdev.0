From: Michael Spang <mspang@csclub.uwaterloo.ca>
Subject: Re: [PATCH] Revert netlink ABI change to gnet_stats_basic
Date: Sun, 16 Aug 2009 09:42:49 -0400
Message-ID: <118a63b80908160642j73568637n2f3fa97fc33d8e57@mail.gmail.com>
References: <1250002683-28554-1-git-send-email-mspang@csclub.uwaterloo.ca>
	 <4A87FCAC.5070705@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.247]:61120 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750919AbZHPNtf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Aug 2009 09:49:35 -0400
In-Reply-To: <4A87FCAC.5070705@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 16, 2009 at 8:33 AM, Eric Dumazet<eric.dumazet@gmail.com> wrote:
>
> What exactly broke after patch was pushed ?

The libnl library refuses to initialize with 2.6.30 with pre-2.6.30
headers. With 2.6.30 I get

  $ libnl-1.1/src/nl-qdisc-dump brief
  Unable to retrieve qdisc cache

whereas previously I would get

  $ libnl-1.1/src/nl-qdisc-dump brief
  htb qdisc dev eth0 handle 01: parent root r2q 10000 default :02

It works fine if I use the headers from 2.6.30, but then I don't
believe it would work with older kernels.

Michael
