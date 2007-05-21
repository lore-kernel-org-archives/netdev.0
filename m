From: "Jun Koi" <junkoi2004@gmail.com>
Subject: Re: [Xen-devel] [PATCH 0/4] [Net] Support Xen accelerated network plugin modules
Date: Mon, 21 May 2007 19:02:07 +0900
Message-ID: <fdaac4d50705210302q7533227bkfc302aa9cee901b5@mail.gmail.com>
References: <1179494148.14376.7.camel@moonstone.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xensource.com, muli@il.ibm.com,
	netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: "Kieran Mansley" <kmansley@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:7245 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755219AbXEUKCR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 May 2007 06:02:17 -0400
Received: by ug-out-1314.google.com with SMTP id 44so1146454uga
        for <netdev@vger.kernel.org>; Mon, 21 May 2007 03:02:16 -0700 (PDT)
In-Reply-To: <1179494148.14376.7.camel@moonstone.uk.level5networks.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/18/07, Kieran Mansley <kmansley@solarflare.com> wrote:
> This is a repost of some earlier patches to the xen-devel mailing list,
> with a number of changes thanks to some useful suggestions from others.
> Apologies for the short delay in getting this next version ready.
>
> I've also CC'd netdev@vger.kernel.org as some of the files being patched
> may be merged into upstream linux soon, and so folks there may have
> opinions too.
>
> This set of patches provides the hooks and support necessary for
> accelerated network plugin modules to attach to Xen's netback and
> netfront.  These modules provide a fast path for network traffic where
> there is hardware support available for the netfront driver to send and
> receive packets directly to a NIC (such as those available from
> Solarflare).
>

Hi Kieran,

This is interesting. Just a question: is this possible for more than 1
domain to access directly to NIC, or at a time only 1 domain can do
that?

Thanks,
Jun
