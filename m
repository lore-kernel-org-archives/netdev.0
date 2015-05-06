From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] mpls: Move reserved label definitions
Date: Wed, 6 May 2015 15:16:56 -0700
Message-ID: <20150506151656.137a0542@urahara>
References: <1430841990-2828702-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <ebiederm@xmission.com>,
	<netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34312 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751069AbbEFWQx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 18:16:53 -0400
Received: by pacyx8 with SMTP id yx8so21331580pac.1
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 15:16:53 -0700 (PDT)
In-Reply-To: <1430841990-2828702-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 5 May 2015 09:06:30 -0700
Tom Herbert <tom@herbertland.com> wrote:

> Move to include/uapi/linux/mpls.h to be externally visibile.
> 
> Signed-off-by: Tom Herbert <tom@herbertland.com>
> ---
>  include/uapi/linux/mpls.h | 10 ++++++++++
>  net/mpls/af_mpls.c        | 18 +++++++++---------
>  net/mpls/internal.h       | 10 ----------
>  3 files changed, 19 insertions(+), 19 deletions(-)
> 
> diff --git a/include/uapi/linux/mpls.h b/include/uapi/linux/mpls.h

You need to update include/uapi/linux/Kbuild to cause header
to be exported.
