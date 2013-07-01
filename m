From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH v2.34] datapath: Add basic MPLS support to kernel
Date: Mon, 1 Jul 2013 16:42:46 -0700
Message-ID: <CAEP_g=-uMQuwK7=35XG8xrToFDoe8HS8yBK51tSWOipS0FdYtA@mail.gmail.com>
References: <1372234717-8735-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>, Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Pravin B Shelar <pshelar@nicira.com>,
	Jarno Rajahalme <jarno.rajahalme@nsn.com>,
	Joe Stringer <joe@wand.net.nz>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog118.obsmtp.com ([74.125.149.244]:51687 "HELO
	na3sys009aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755033Ab3GAXnH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jul 2013 19:43:07 -0400
Received: by mail-ie0-f174.google.com with SMTP id 9so10415883iec.19
        for <netdev@vger.kernel.org>; Mon, 01 Jul 2013 16:43:06 -0700 (PDT)
In-Reply-To: <1372234717-8735-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 26, 2013 at 1:18 AM, Simon Horman <horms@verge.net.au> wrote:
> Allow datapath to recognize and extract MPLS labels into flow keys
> and execute actions which push, pop, and set labels on packets.
>
> Based heavily on work by Leo Alterman, Ravi K, Isaku Yamahata and Joe Stringer.
>
> Cc: Ravi K <rkerur@gmail.com>
> Cc: Leo Alterman <lalterman@nicira.com>
> Cc: Isaku Yamahata <yamahata@valinux.co.jp>
> Cc: Joe Stringer <joe@wand.net.nz>
> Signed-off-by: Simon Horman <horms@verge.net.au>

Simon, have you thought any more about the header ordering issues? I
don't think we've reached a conclusion at this point.
