From: Joseph Fannin <jfannin@gmail.com>
Subject: Re: [PATCH] fix ACK processing after netlink_dump_start
Date: Tue, 23 Oct 2007 11:36:18 -0400
Message-ID: <20071023153618.GA30941@nineveh.local>
References: <20071023144023.GA15035@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dcbw@redhat.com, tgraf@suug.ch, jfannin@gmail.com,
	davem@davemloft.net, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru
To: "Denis V. Lunev" <den@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.234]:61967 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751862AbXJWPhP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2007 11:37:15 -0400
Received: by nz-out-0506.google.com with SMTP id s18so791962nze
        for <netdev@vger.kernel.org>; Tue, 23 Oct 2007 08:37:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20071023144023.GA15035@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 23, 2007 at 06:40:23PM +0400, Denis V. Lunev wrote:
> Revert to original netlink behavior. Do not reply with ACK if the
> netlink dump has bees successfully started.
>
> libnl has been broken by the cd40b7d3983c708aabe3d3008ec64ffce56d33b0
> The following command reproduce the problem:
>    /nl-route-get 192.168.1.1
>
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Network Manager works correctly here with this patch applied against
Linus's current -git.

(Sorry for the lack of response before -- I think I forgot to ask to
be CC'd on replies, and found the discussion of this in archives
only this morning.)

--
Joseph Fannin
jfannin@gmail.com

