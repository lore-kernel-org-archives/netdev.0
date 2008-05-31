From: "Adam Langley" <agl@imperialviolet.org>
Subject: Re: [PATCH] Fix corrupt TCP packets when options space overflows with MD5SIG enabled
Date: Sat, 31 May 2008 15:01:56 -0700
Message-ID: <396556a20805311501n81696degf41c49d98192b54d@mail.gmail.com>
References: <396556a20805301140x586093e5o92d44e38f7c2869a@mail.gmail.com>
	 <20080530190218.GD1743@solarflare.com>
	 <396556a20805301211g7dd98ae7m185a356e611e81aa@mail.gmail.com>
	 <396556a20805301217k293e5718h6bbf02bfe0683142@mail.gmail.com>
	 <20080530133236.24675c23@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Ben Hutchings" <bhutchings@solarflare.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: "Stephen Hemminger" <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.231]:60152 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753790AbYEaWCC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 May 2008 18:02:02 -0400
Received: by rv-out-0506.google.com with SMTP id l9so418045rvb.1
        for <netdev@vger.kernel.org>; Sat, 31 May 2008 15:02:01 -0700 (PDT)
In-Reply-To: <20080530133236.24675c23@extreme>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 30, 2008 at 1:32 PM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> Your mailer is wrapping lines so patch is munged.

Will use a better MUA in future, thanks.

> You can just do:
>
> +       struct tcp_md5sig_key *md5 = NULL;
>  #ifdef CONFIG_TCP_MD5SIG
> -       struct tcp_md5sig_key *md5;
>        __u8 *md5_hash_location;
>  #endif

Will do; hopefully final version of the patch coming in a second.. thanks


AGL

-- 
Adam Langley agl@imperialviolet.org http://www.imperialviolet.org
