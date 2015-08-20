From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: Exporting obscene amounts of data in rtnl_link_ops->fill_info()
Date: Thu, 20 Aug 2015 16:57:12 +0200
Message-ID: <CAHmME9qGhwd7D2rztV9zqstzuWPG-Pn9ag3a-trTdH6nOAgdMw@mail.gmail.com>
References: <CAHmME9pps6BJwubBNgp294JKGkGXHUyb1kMdTGCEwok__aQjmw@mail.gmail.com>
	<CAE4R7bDhn02qVsn3fja16uz3wOXycZHfXHYynOOdWGJzY2UOhQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAE4R7bDhn02qVsn3fja16uz3wOXycZHfXHYynOOdWGJzY2UOhQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 20, 2015 at 7:59 AM, Scott Feldman <sfeldma@gmail.com> wrote:
>
> What kind of data are you sending up?  Maybe there is an alternate interface.

This is what I'm wondering about: alternative interfaces, that are
still kosher in the netlink/rtnl world. Each interface is associated
with a certain set of "peers". I want to get a list of all these
peers. Sometimes there are lots of them. It's structured data that
fits well into netlink messages, but it's just that there are
potentially a lot of entries.
