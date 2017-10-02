From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 0/3] bridge: neigh msg proxy and flood
 suppression support
Date: Mon, 2 Oct 2017 11:02:24 -0700
Message-ID: <20171002110224.4d789600@xeon-e3>
References: <1506919018-27875-1-git-send-email-roopa@cumulusnetworks.com>
        <CAJieiUim2XLMGAomb3S5AeWfYqjxV_raetedWcA_PBiaGPRHWg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        bridge@lists.linux-foundation.org
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:43444 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751236AbdJBSCc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 14:02:32 -0400
Received: by mail-pf0-f177.google.com with SMTP id d2so72533pfh.0
        for <netdev@vger.kernel.org>; Mon, 02 Oct 2017 11:02:32 -0700 (PDT)
In-Reply-To: <CAJieiUim2XLMGAomb3S5AeWfYqjxV_raetedWcA_PBiaGPRHWg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2 Oct 2017 07:49:09 -0700
Roopa Prabhu <roopa@cumulusnetworks.com> wrote:

> On Sun, Oct 1, 2017 at 9:36 PM, Roopa Prabhu <roopa@cumulusnetworks.com> wrote:
> > From: Roopa Prabhu <roopa@cumulusnetworks.com>
> >
> > This series implements arp and nd suppression in the bridge
> > driver for ethernet vpns. It implements rfc7432, section 10
> > https://tools.ietf.org/html/rfc7432#section-10
> > for ethernet VPN deployments. It is similar to the existing
> > BR_ARP_PROXY flag but has a few semantic differences to conform
> > to EVPN standard. In case of EVPN, it is mainly used to avoid flooding to
> > tunnel ports like vxlan/mpls. Unlike the existing flags it suppresses flood
> > of all neigh discovery packets (arp, nd) to tunnel ports.
> >
> > Roopa Prabhu (3):
> >   bridge: add new BR_NEIGH_SUPPRESS port flag to suppress arp and nd
> >     flood
> >   neigh arp suppress first
> >   bridge: suppress nd messages from going to BR_NEIGH_SUPPRESS ports
> >  
> 
> pls ignore, shows conflict applying over recent net-next bridge
> changes. Will rebase and submit v2.

Ok, but the concept looks good.
