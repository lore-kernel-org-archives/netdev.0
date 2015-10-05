From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next v2 13/13] rocker: move OF-DPA stuff into separate file
Date: Mon, 5 Oct 2015 10:59:48 -0700
Message-ID: <CAE4R7bAJZy2-WODSSvq9uSHzSEKPO4CJdyy2ZULKna6XNcdVgw@mail.gmail.com>
References: <1444067046-27825-1-git-send-email-jiri@resnulli.us> <1444067046-27825-14-git-send-email-jiri@resnulli.us>
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
Received: from mail-ob0-f173.google.com ([209.85.214.173]:36773 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752099AbbJESAI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 14:00:08 -0400
Received: by obcgx8 with SMTP id gx8so134809193obc.3
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 11:00:07 -0700 (PDT)
In-Reply-To: <1444067046-27825-14-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 5, 2015 at 10:44 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> Carve out OF-DPA would specific code from the common file to the world
> file. This change required struct rocker and struct rocker_port split
> into world specific struct ofdpa and struct ofdpa_port. Along with this
> the world specific functions and defines were renamed from prefix
> "rocker_" to "ofdpa_".
>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

I'd like a chance to run tests against this patchset and study the
patches closer.  It's going to take a couple of days, so I'd like to
ask that we take a little bit of time before merging this in.  It's
all good work; just want to do due-diligence before it's pushed.
