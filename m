From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] iproute: disallow ip rule del without parameters
Date: Thu, 1 Sep 2016 09:05:40 -0700
Message-ID: <20160901090540.707a6c87@xeon-e3>
References: <20160824204252.2melotzdx6ftzgaq@ppc.Dlink>
        <20160829105325.40230e41@xeon-e3>
        <20160830115156.GB17087@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Andrey Jr. Melnikov" <temnota.am@gmail.com>,
        Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:33077 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934058AbcIAQFf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 12:05:35 -0400
Received: by mail-pf0-f175.google.com with SMTP id g202so9615496pfb.0
        for <netdev@vger.kernel.org>; Thu, 01 Sep 2016 09:05:34 -0700 (PDT)
In-Reply-To: <20160830115156.GB17087@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 30 Aug 2016 13:51:56 +0200
Michal Kubecek <mkubecek@suse.cz> wrote:

> On Mon, Aug 29, 2016 at 10:53:25AM -0700, Stephen Hemminger wrote:
> > On Wed, 24 Aug 2016 23:43:00 +0300
> > "Andrey Jr. Melnikov" <temnota.am@gmail.com> wrote:
> >   
> > > Disallow run `ip rule del` without any parameter to avoid delete any first
> > > rule from table.  
> ...
> > Actually ip rule delete without arguments deletes all rules.
> > Which could be a bug or feature depending on the user.
> > I can imagine somebody is doing something like deleting all rules
> > and putting in new ones for PBR.  
> 
> We have "ip rule flush" for that, don't we?
> 
> Michal Kubecek

I went ahead and applied this, seemed better to give error than deleting
all rules.
