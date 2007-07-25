From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH 02/12 -Rev2] Changes to netdevice.h
Date: Wed, 25 Jul 2007 10:10:01 +0530
Message-ID: <OF5F147E87.14E3EA55-ON65257323.0018FC99-65257323.0019A2EE@in.ibm.com>
References: <OFFAB073E4.487DACF3-ON65257321.00101BE3-65257321.00104971@LocalDomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem@davemloft.net, gaagaan@gmail.com,
	general@lists.openfabrics.org, hadi@cyberus.ca,
	herbert@gondor.apana.org.au, jagana@us.ibm.com, jeff@garzik.org,
	johnpol@2ka.mipt.ru, Patrick McHardy <kaber@trash.net>,
	kumarkr@linux.ibm.com, mcarlson@broadcom.com, mchan@broadcom.com,
	netdev@vger.kernel.org, peter.p.waskiewicz.jr@intel.com,
	rdreier@cisco.com, rick.jones2@hp.com, Robert.Olsson@data.slu.se,
	sri@us.ibm.com, tgraf@suug.ch, xma@us.ibm.com
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp05.au.ibm.com ([202.81.18.154]:58302 "EHLO
	ausmtp05.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751431AbXGYEkD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2007 00:40:03 -0400
Received: from d23relay01.au.ibm.com (d23relay01.au.ibm.com [202.81.18.232])
	by ausmtp05.au.ibm.com (8.13.8/8.13.8) with ESMTP id l6P4f6mo430264
	for <netdev@vger.kernel.org>; Wed, 25 Jul 2007 14:41:06 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.250.242])
	by d23relay01.au.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6P4dIwH212704
	for <netdev@vger.kernel.org>; Wed, 25 Jul 2007 14:39:18 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6P4dsZe027051
	for <netdev@vger.kernel.org>; Wed, 25 Jul 2007 14:39:55 +1000
In-Reply-To: <OFFAB073E4.487DACF3-ON65257321.00101BE3-65257321.00104971@LocalDomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Patrick,

Krishna Kumar2/India/IBM wrote on 07/23/2007 08:27:53 AM:

> Hi Patrick,
>
> Patrick McHardy <kaber@trash.net> wrote on 07/22/2007 10:36:51 PM:
>
> > Krishna Kumar wrote:
> > > @@ -472,6 +474,9 @@ struct net_device
> > >     void         *priv;   /* pointer to private data   */
> > >     int         (*hard_start_xmit) (struct sk_buff *skb,
> > >                        struct net_device *dev);
> > > +   int         (*hard_start_xmit_batch) (struct net_device
> > > +                       *dev);
> > > +
> >
> >
> > Os this function really needed? Can't you just call hard_start_xmit
with
> > a NULL skb and have the driver use dev->blist?

> Probably not. I will see how to do it this way and get back to you.

I think this is a good idea and makes code everywhere simpler. I
will try this change and test to make sure it doesn't have any
negative impact. Will mostly send out rev3 tomorrow.

Thanks,

- KK

