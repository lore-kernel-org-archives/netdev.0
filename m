From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [Patch net 2/3] ipv4,fib: pass LOOPBACK_IFINDEX instead of 0 to
 flowi4_iif
Date: Tue, 15 Apr 2014 23:26:53 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1404152315130.1549@ja.home.ssi.bg>
References: <1397525608-11592-1-git-send-email-xiyou.wangcong@gmail.com> <1397525608-11592-2-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Eric Biederman <ebiederm@xmission.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:59581 "EHLO ja.home.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752340AbaDOU1b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2014 16:27:31 -0400
In-Reply-To: <1397525608-11592-2-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Mon, 14 Apr 2014, Cong Wang wrote:

> From: Cong Wang <cwang@twopensource.com>
> 
> flowi4_iif should be LOOPBACK_IFINDEX by default.

	Looks good to me, you included all needed changes
into the 3 patches. After checking all fib_lookup() callers
I see one remaining place to be fixed, if we want to be
pedantic: fib_check_nh() needs a LOOPBACK_IFINDEX for fl4.

Regards

--
Julian Anastasov <ja@ssi.bg>
