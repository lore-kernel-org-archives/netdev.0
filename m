From: Eugene Teo <eteo@redhat.com>
Subject: Re: [PATCH] sctp: add verification checks to SCTP_AUTH_KEY option
Date: Tue, 26 Aug 2008 11:01:05 +0800
Message-ID: <48B371F1.5080605@redhat.com>
References: <20080825164440.GA504@kernel.sg> <12196959323990-git-send-email-vladislav.yasevich@hp.com> <48B35561.2010001@redhat.com> <48B35B59.2020208@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, security@kernel.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:43590 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753851AbYHZDBY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Aug 2008 23:01:24 -0400
In-Reply-To: <48B35B59.2020208@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vlad Yasevich wrote:
> Eugene Teo wrote:
>> Vlad Yasevich wrote:
[...]
>>> +	if (authkey->sca_keylength > optlen) {
>>> +		ret = -EINVAL;
>>> +		goto out;
>> Is there a better upper bound check?
> 
> Hm...  optlen - sizeof(struct sctp_authkey)  is more accurate.
> 
> There is really no other bound.

Linus suggested that it is better to declare an upper bound for key_len.
I think it makes a lot of sense as a key shouldn't be as long as the
boundary limit of its declared data type.

Thanks,
Eugene
