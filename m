From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC 2/9] ipv6: sr: add code base for control plane support of
 SR-IPv6
Date: Wed, 31 Aug 2016 10:10:28 -0700
Message-ID: <20160831101028.7ea13fb4@xeon-e3>
References: <1472226767-9904-1-git-send-email-david.lebrun@uclouvain.be>
        <1472226767-9904-3-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Lebrun <david.lebrun@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:33230 "EHLO
        mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934320AbcHaRKU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 13:10:20 -0400
Received: by mail-pa0-f49.google.com with SMTP id cy9so20507694pac.0
        for <netdev@vger.kernel.org>; Wed, 31 Aug 2016 10:10:19 -0700 (PDT)
In-Reply-To: <1472226767-9904-3-git-send-email-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 26 Aug 2016 17:52:40 +0200
David Lebrun <david.lebrun@uclouvain.be> wrote:

> +
> +static inline struct seg6_pernet_data *seg6_pernet(struct net *net)
> +{
> +	return net->ipv6.seg6_data;
> +}
> +
> +static inline void seg6_pernet_lock(struct net *net)
> +{
> +	spin_lock(&seg6_pernet(net)->lock);
> +}
> +
> +static inline void seg6_pernet_unlock(struct net *net)
> +{
> +	spin_unlock(&seg6_pernet(net)->lock);
> +}

Since these are for control operations why a mutex?
