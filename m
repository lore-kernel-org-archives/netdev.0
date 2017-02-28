From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] iproute2: show network device dependency tree
Date: Tue, 28 Feb 2017 22:47:34 +0100
Message-ID: <20170228214734.GE1982@nanopsycho>
References: <20170225165900.10129-1-zaboj.campula@post.cz>
 <20170227105524.64731e21@xeon-e3>
 <1488313163.2131.3.camel@post.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org
To: Zaboj Campula <zaboj.campula@post.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:35842 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751722AbdB1VtP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2017 16:49:15 -0500
Received: by mail-wr0-f195.google.com with SMTP id l37so3189461wrc.3
        for <netdev@vger.kernel.org>; Tue, 28 Feb 2017 13:47:37 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1488313163.2131.3.camel@post.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Feb 28, 2017 at 09:19:23PM CET, zaboj.campula@post.cz wrote:
>On Mon, 2017-02-27 at 10:55 -0800, Stephen Hemminger wrote:
>> 
>> Another alternative format would be to make -tree a output modifier and ident (like ps tree options).
>> 
>> $ ip -t link
>> 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1
>>     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
>> 8: bond0 <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast state DOWN mode DEFAULT group default qlen 1000
>>     link/ether 52:54:00:66:24:cd brd ff:ff:ff:ff:ff:ff 
>>     2: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast master bond0 state DOWN mode DEFAULT group default qlen 1000
>>         link/ether 52:54:00:66:24:cd brd ff:ff:ff:ff:ff:ff
>
>OK, it looks better because the information is complete.
>
>I looked at several tree printing utilities and I like
>the lsblk format. But tabular format does not fit the ip-show
>well. I will try to indent the current ip-show output may be
>with fancy lines.

I don't really think that the output you provide has any value. As JiriB
wrote, it is really problematic to draw relationships between devices.
Let's take OVS as a very non-trivial example. Your patch aims to handle
only the very basic ones.
