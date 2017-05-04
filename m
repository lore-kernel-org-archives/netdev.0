From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: struct ip vs struct iphdr
Date: Thu, 4 May 2017 12:52:48 -0400
Message-ID: <20170504165248.GI7300@oracle.com>
References: <20170504164219.GA25287@legohost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Oleg <lego12239@yandex.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:39225 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755774AbdEDQwp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 12:52:45 -0400
Content-Disposition: inline
In-Reply-To: <20170504164219.GA25287@legohost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (05/04/17 19:42), Oleg wrote:
> 
>   Hi, all.
> 
> It seems struct ip and struct iphdr are similar: struct ip, despite of
> it name, doesn't contain anything but ip header.
> 
> So, my noob question, what is the difference between them?
> 
> Thanks.

BSD vs linux?

struct ip is a BSD-ism, intended to be used if you were porting
some BSD app.

--Sowmini
