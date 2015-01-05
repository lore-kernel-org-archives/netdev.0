From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH/RFC flow-net-next 02/10] net: flow: Add features to tables
Date: Mon, 5 Jan 2015 11:18:58 +0900
Message-ID: <20150105021855.GE15716@vergenet.net>
References: <1419819340-19000-1-git-send-email-simon.horman@netronome.com>
 <1419819340-19000-3-git-send-email-simon.horman@netronome.com>
 <CAHA+R7NmfUpYcKfW_Gck2HaANH3OQk-9BAYZCXnBtGO1eV13xg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:64173 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751773AbbAECTI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jan 2015 21:19:08 -0500
Received: by mail-pd0-f182.google.com with SMTP id p10so27168257pdj.13
        for <netdev@vger.kernel.org>; Sun, 04 Jan 2015 18:19:07 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAHA+R7NmfUpYcKfW_Gck2HaANH3OQk-9BAYZCXnBtGO1eV13xg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 29, 2014 at 03:03:39PM -0800, Cong Wang wrote:
> On Sun, Dec 28, 2014 at 6:15 PM, Simon Horman
> <simon.horman@netronome.com> wrote:
> > +static struct net_flow_table *net_flow_table_get_table(struct net_device *dev,
> > +                                                      int table_uid)
> > +{
> > +       struct net_flow_table **tables;
> > +       int i;
> > +
> > +       tables = net_flow_get_tables(dev);
> > +       if (IS_ERR(tables))
> > +               return ERR_PTR(PTR_ERR(tables));
> 
> Seriously? :)

I was looking for a way to handle the type of tables being different
to the return type of net_flow_table_get_table().

Would you recommend a cast?

		return (struct net_flow_table *)tables;
