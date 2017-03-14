From: Andy Zhou <azhou@ovn.org>
Subject: Re: [net-next sample action optimization 3/3] openvswitch: Optimize
 sample action for the clone use cases
Date: Tue, 14 Mar 2017 16:11:20 -0700
Message-ID: <CABKoBm1hX7eBmoOJED2MfLh5O16j5HvdUu+uT5Y90+9SLZ_eMg@mail.gmail.com>
References: <1489193500-15260-1-git-send-email-azhou@ovn.org>
 <1489193500-15260-4-git-send-email-azhou@ovn.org> <CAOrHB_CNyhQM5wVJvYNQtE8+RKLAbPrjsrQtbGe-poHi+5AW+g@mail.gmail.com>
 <CABKoBm14S4QRZCNYqBdfcVXrmvDnf3xrRXbDsBKGsMufdgeXZQ@mail.gmail.com>
 <CABKoBm01ieuSrbhf7yZH9AzZkTNB=kiOAhYTDoinXRtDhQoFoQ@mail.gmail.com> <CAOrHB_Ciq+txB+-yY5YKKxVCA61WS9y8HOUAjQjApwC2UKd9dw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Joe Stringer <joe@ovn.org>
To: Pravin Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay6-d.mail.gandi.net ([217.70.183.198]:44326 "EHLO
        relay6-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750796AbdCNXMF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 19:12:05 -0400
Received: from mfilter28-d.gandi.net (mfilter28-d.gandi.net [217.70.178.159])
        by relay6-d.mail.gandi.net (Postfix) with ESMTP id F1BB7FB89E
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 00:12:03 +0100 (CET)
Received: from relay6-d.mail.gandi.net ([IPv6:::ffff:217.70.183.198])
        by mfilter28-d.gandi.net (mfilter28-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id Oaa3GppOVWFs for <netdev@vger.kernel.org>;
        Wed, 15 Mar 2017 00:12:02 +0100 (CET)
Received: from mail-pf0-f174.google.com (mail-pf0-f174.google.com [209.85.192.174])
        (Authenticated sender: azhou@ovn.org)
        by relay6-d.mail.gandi.net (Postfix) with ESMTPSA id 3B00CFB87E
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 00:12:02 +0100 (CET)
Received: by mail-pf0-f174.google.com with SMTP id o126so399161pfb.3
        for <netdev@vger.kernel.org>; Tue, 14 Mar 2017 16:12:02 -0700 (PDT)
In-Reply-To: <CAOrHB_Ciq+txB+-yY5YKKxVCA61WS9y8HOUAjQjApwC2UKd9dw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Actions parameter which hints if it is recirc or sample. We can add
> recic-id param and set it if it is recic case.
> will this work?
>
Just posted v2.  I added a patch in the end to implement this
refactoring as suggested.
