From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH -next] 6lowpan: reassembly: un-export local functions
Date: Thu, 13 Mar 2014 23:46:44 +0100
Message-ID: <20140313224642.GA14644@omega>
References: <1394740683-6910-1-git-send-email-fw@strlen.de>
 <20140313.161031.1512355631528238438.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: fw@strlen.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:62483 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755003AbaCMWqy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2014 18:46:54 -0400
Received: by mail-ee0-f46.google.com with SMTP id t10so680609eei.5
        for <netdev@vger.kernel.org>; Thu, 13 Mar 2014 15:46:53 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140313.161031.1512355631528238438.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Thu, Mar 13, 2014 at 04:10:31PM -0400, David Miller wrote:
> From: Florian Westphal <fw@strlen.de>
> Date: Thu, 13 Mar 2014 20:58:03 +0100
> 
> > most of these are only used locally, make them static.
> > fold lowpan_expire_frag_queue into its caller, its small enough.
> > 
> > Cc: Alexander Aring <alex.aring@gmail.com>
> > Signed-off-by: Florian Westphal <fw@strlen.de>
> > ---
> >  Compile tested only.
> > 
> >  Seems this was cloned off ipv6/reassembly.c which exports
> >  some function for ipv6 netfilter defrag, these exports
> >  seem to be unneeded for 6lowpan.
> 
> Looks like a completely accurate assesment to me, applied.

yes indeed. Sorry, thanks for fixing this Florian.

- Alex
