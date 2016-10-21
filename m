From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: network packet kernel rate limit
Date: Fri, 21 Oct 2016 10:41:47 -0700
Message-ID: <CAM_iQpWT3EDqx9WSfso6BVeMuo_gsEsgBJx3prOQcT7_0kd28Q@mail.gmail.com>
References: <8729016553E3654398EA69218DA29EEF5CB42C@cnshjmbx02>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: YUAN Linyu <Linyu.Yuan@alcatel-sbell.com.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f44.google.com ([209.85.214.44]:36583 "EHLO
        mail-it0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932507AbcJURmJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 13:42:09 -0400
Received: by mail-it0-f44.google.com with SMTP id 139so236163008itm.1
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 10:42:08 -0700 (PDT)
In-Reply-To: <8729016553E3654398EA69218DA29EEF5CB42C@cnshjmbx02>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 20, 2016 at 11:17 PM, YUAN Linyu
<Linyu.Yuan@alcatel-sbell.com.cn> wrote:
> User space application require linux kernel to do rate limit to some type of Ethernet packet(ARP, ICMP, TCP, for example 1000 packet/s) when system run under Ethernet packet flooding test.
> Do you know if kernel already exist a feature to implement this requirement?

There are multiple Qdisc's for rate limiting, e.g.:
http://lartc.org/manpages/tc-htb.html
