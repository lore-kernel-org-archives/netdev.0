From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [RFC] netlink: send exterr cookie on success
Date: Sat, 8 Apr 2017 11:28:43 -0400
Message-ID: <20170408112844.3aa4d448@griffin>
References: <20170407194402.4181-1-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        pablo@netfilter.org, Jamal Hadi Salim <jhs@mojatatu.com>,
        Johannes Berg <johannes.berg@intel.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41552 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751137AbdDHP2v (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 8 Apr 2017 11:28:51 -0400
In-Reply-To: <20170407194402.4181-1-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  7 Apr 2017 21:44:02 +0200, Johannes Berg wrote:
> @@ -67,6 +67,8 @@ struct netlink_ext_err {
>  	u32 ext_code;
>  	u32 msg_offset;
>  	u16 attr;
> +	const u8 *cookie;
> +	u8 cookie_len;
>  };

Perhaps the structure should be named just "netlink_ext" or so? It
seems it'll pick up some non-error related usage, such as the cookies
here or, in the future, flags indicating how the message should be
parsed.

Thanks,

 Jiri
