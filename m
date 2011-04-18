From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: [PATCH net-next-2.6 0/3] new SCTP sockets APIs
Date: Mon, 18 Apr 2011 11:47:07 +0800
Message-ID: <4DABB43B.9010204@cn.fujitsu.com>
References: <4DABAEF1.1010506@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	lksctp <linux-sctp@vger.kernel.org>
To: Wei Yongjun <yjwei@cn.fujitsu.com>,
	David Miller <davem@davemloft.net>,
	Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:53511 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751923Ab1DRDvB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Apr 2011 23:51:01 -0400
In-Reply-To: <4DABAEF1.1010506@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To David, Vlad:

   There are many patches in vlad's net-next(1*) tree besides these three ones.
   Maybe vlad is busy doing other things, Should we need to respin these patches
   base on latest kernel and submit to you? So we can do further work against latest kernel.   

   1*: vlad's net-next tree:
      http://git.kernel.org/?p=linux/kernel/git/vxy/lksctp-dev.git;a=shortlog;h=refs/heads/net-next


Wei Yongjun wrote, at 04/18/2011 11:24 AM:
> This patchset implement some new sockets APIs for net-next-2.6.
> 
> Wei Yongjun (3):
>   sctp: implement socket option SCTP_GET_ASSOC_ID_LIST
>   sctp: change auth event type name to SCTP_AUTHENTICATION_EVENT
>   sctp: implement event notification SCTP_SENDER_DRY_EVENT
> 
>  include/net/sctp/sm.h       |    1 +
>  include/net/sctp/ulpevent.h |    3 ++
>  include/net/sctp/user.h     |   33 ++++++++++++++++++++++++++-
>  net/sctp/sm_statefuns.c     |   24 +++++++++++++++++++
>  net/sctp/sm_statetable.c    |    2 +-
>  net/sctp/socket.c           |   52 +++++++++++++++++++++++++++++++++++++++++++
>  net/sctp/ulpevent.c         |   30 ++++++++++++++++++++++++-
>  7 files changed, 142 insertions(+), 3 deletions(-)
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


-- 

Best Regards
-----
Shan Wei
