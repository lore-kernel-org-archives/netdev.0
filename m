From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Subject: Re: removing gotos considered harmful...
Date: Fri, 22 Dec 2006 19:11:48 -0200
Message-ID: <39e6f6c70612221311t277f28a2j6378bcef7ad4c374@mail.gmail.com>
References: <20061222.120432.55508411.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.227]:31717 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752878AbWLVVLt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Dec 2006 16:11:49 -0500
Received: by wx-out-0506.google.com with SMTP id h27so2838547wxd
        for <netdev@vger.kernel.org>; Fri, 22 Dec 2006 13:11:48 -0800 (PST)
To: "David Miller" <davem@davemloft.net>
In-Reply-To: <20061222.120432.55508411.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/22/06, David Miller <davem@davemloft.net> wrote:
>
> Because of massively painful regressions like the following,
> I absolutely refuse to apply "cleanup" patches to remove gotos
> for "clarity".  All such patches do is change the code and
> potentially add bugs, they don't help in any way at all.
>
> Gerrit, please be more careful next time, and resist the urge to "fix"
> stuff that isn't broken just to satisfy your own personal coding
> tastes during a conversion.  This is a locally exploitable hole,
> all someone has to do is open a few hundred UDP sockets to a
> particular destination port and then nobody, not even root, can
> so much as run ping successfully.
>
> Arnaldo, sorry I originally thought this bug was added by you, you're
> totally innocent this time :-)))

Was so fast I wasn't even able to plead "not guilty!" :-)

- Arnaldo
