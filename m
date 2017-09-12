From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net] mlxsw: spectrum: Prevent mirred-related crash on
 removal
Date: Tue, 12 Sep 2017 15:15:50 +0200
Message-ID: <20170912131550.GK2036@nanopsycho>
References: <20170912065053.1392-1-jiri@resnulli.us>
 <20170912130506.GB32598@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, yuvalm@mellanox.com,
        idosch@mellanox.com, flokli@flokli.de, mlxsw@mellanox.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f175.google.com ([209.85.128.175]:34514 "EHLO
        mail-wr0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751289AbdILNPw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2017 09:15:52 -0400
Received: by mail-wr0-f175.google.com with SMTP id v109so22240059wrc.1
        for <netdev@vger.kernel.org>; Tue, 12 Sep 2017 06:15:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170912130506.GB32598@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Sep 12, 2017 at 03:05:06PM CEST, andrew@lunn.ch wrote:
>On Tue, Sep 12, 2017 at 08:50:53AM +0200, Jiri Pirko wrote:
>> From: Yuval Mintz <yuvalm@mellanox.com>
>
>Hi Jiri, Yuval
>
>s/mirred/mirrored/g

Actually, the name of the tc action is indeed "mirred".
See net/sched/act_mirred.c
