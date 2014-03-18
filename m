From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCHv2 net-next] VXLAN: fix nonfunctional neigh_reduce
Date: Tue, 18 Mar 2014 08:46:48 -0700
Message-ID: <20140318084648.4811a73b@nehalam.linuxnetplumber.net>
References: <201403181521.s2IFL99N027716@lab1.dls>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Cong Wang <amwang@redhat.com>, netdev@vger.kernel.org
To: David L Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:63158 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753971AbaCRPqw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 11:46:52 -0400
Received: by mail-pa0-f50.google.com with SMTP id kq14so7538197pab.9
        for <netdev@vger.kernel.org>; Tue, 18 Mar 2014 08:46:51 -0700 (PDT)
In-Reply-To: <201403181521.s2IFL99N027716@lab1.dls>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 18 Mar 2014 11:21:09 -0400
David L Stevens <dlstevens@us.ibm.com> wrote:

> +out:
> +	if (reply)
> +		kfree_skb(reply);
> +	return 0;
> +}

Will cause sparse warning about use of 0 as NULL
