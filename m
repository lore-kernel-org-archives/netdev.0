From: Andrew Collins <bsderandrew@gmail.com>
Subject: Missed stable line commit (upstream 859828c0ea476b42f3a93d69d117aaba90994b6f)
Date: Mon, 3 Nov 2014 15:11:01 -0700
Message-ID: <CAKTPYJQQprPnN1bUPxy32YREb8WARQztQYWL9-Qfhm6wLqbD0A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	stable@vger.kernel.org, gregkh@linuxfoundation.org
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I ran into an issue today on latest 3.10 stable line that looks to
have been resolved upstream and tagged for stable:

commit 859828c0ea476b42f3a93d69d117aaba90994b6f
Author: Jiri Pirko <jiri@resnulli.us>
Date:   Thu Dec 5 16:27:37 2013 +0100

    br: fix use of ->rx_handler_data in code executed on non-rx_handler path
    ...
    Please apply to stable trees as well. Thanks.

The commit did make it into the 3.12 stable line, but seems to have
been missed in 3.10.  The commit that causes the issue *did* make it
into 3.10.16 so 3.10 is exposed to the issue:

commit 960b8e5018a552f62cfbc0dfe94be7b6ba178f13
Author: Hong Zhiguo <zhiguohong@tencent.com>
Date:   Sat Sep 14 22:42:28 2013 +0800

    bridge: fix NULL pointer deref of br_port_get_rcu

    [ Upstream commit 716ec052d2280d511e10e90ad54a86f5b5d4dcc2 ]

Any chance 859828c0ea476b42f3a93d69d117aaba90994b6f could be pulled
into the next 3.10 stable?

Thanks,
Andrew Collins
