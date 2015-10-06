From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next v2 01/13] rocker: remove unused rocker_port param
 from alloc funcs and shorten their names
Date: Mon, 5 Oct 2015 21:38:11 -0700
Message-ID: <CAE4R7bCTmUJYWDux8wUaE=+PVTmWJ-ePtxvqP9BnP9ixJHVe7Q@mail.gmail.com>
References: <1444067046-27825-1-git-send-email-jiri@resnulli.us> <1444067046-27825-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>, eladr@mellanox.com,
	Thomas Graf <tgraf@suug.ch>,
	Alexei Starovoitov <ast@plumgrid.com>,
	David Laight <David.Laight@aculab.com>,
	john fastabend <john.fastabend@gmail.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:34226 "EHLO
	mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750934AbbJFEib (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 00:38:31 -0400
Received: by oiev17 with SMTP id v17so102489998oie.1
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 21:38:31 -0700 (PDT)
In-Reply-To: <1444067046-27825-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 5, 2015 at 10:43 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> No need to pass rocker_port around to alloc/free rocker functions,
> since they now use switchdev_trans for memory management storage.
> With the param removal, shorten the name of the functions since they now
> has nothing to do with rocker port.
>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Acked-by: Scott Feldman <sfeldma@gmail.com>
