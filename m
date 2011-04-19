From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: [PATCH net-next-2.6 0/8] sctp: some cleanup and tiny fix for
 add/del ip
Date: Tue, 19 Apr 2011 13:31:27 +0800
Message-ID: <4DAD1E2F.6040907@cn.fujitsu.com>
References: <4DAD18AB.3040401@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	lksctp <linux-sctp@vger.kernel.org>
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60218 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751377Ab1DSFfb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Apr 2011 01:35:31 -0400
In-Reply-To: <4DAD18AB.3040401@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wei Yongjun wrote, at 04/19/2011 01:07 PM:
> Series of 8 patches against net-next-2.6, include some cleanup
> and tiny fix for add/del ip, which have been waiting on vlad's
> lksctp-dev tree for long times.

Thanks for your job, and expect others.

> 
> Shan Wei (5):
>       sctp: delete unused macro definition of sctp_chunk_is_control
>       sctp: fix the comment of sctp_sf_violation_paramlen()
>       sctp: use common head of addr parameter to access member in addr-unrelated code
>       sctp: kill abandoned SCTP_CMD_TRANSMIT command
>       sctp: use memdup_user to copy data from userspace
> 
> Vlad Yasevich (3):
>       sctp: teach CACC algorithm about removed transports
>       sctp: Allow bindx_del to accept 0 port.
>       sctp: Release all routes when processing acks ADD_IP or DEL_IP
> 
>  include/net/sctp/command.h   |    1 -
>  include/net/sctp/constants.h |    1 -
>  net/sctp/input.c             |    2 +-
>  net/sctp/outqueue.c          |   11 ++++++++---
>  net/sctp/sm_make_chunk.c     |   18 +++++++-----------
>  net/sctp/sm_sideeffect.c     |    6 ------
>  net/sctp/sm_statefuns.c      |    5 +++--
>  net/sctp/socket.c            |   28 +++++++++++-----------------
>  8 files changed, 30 insertions(+), 42 deletions(-)
> 
 
-- 
Best Regards
-----
Shan Wei
