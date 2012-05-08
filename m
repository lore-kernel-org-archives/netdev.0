From: "Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: batostr() function
Date: Tue, 8 May 2012 11:26:53 -0700
Message-ID: <CAB=NE6VLbGkXfB+zCt_J3xpiUE7ThE2ynPpGZCGWCE+uE+7u_g@mail.gmail.com>
References: <1336391383.4325.24.camel@jlt3.sipsolutions.net>
 <CANq1E4QW4vSn_r9C=rirShE+-eyPjRX+b5tpC+mx69Hs6aEYqQ@mail.gmail.com>
 <1336487108.4320.2.camel@jlt3.sipsolutions.net> <20120508143011.GD29352@aemeltch-MOBL1>
 <1336497532.29640.24.camel@joe2Laptop> <1336499313.4320.4.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>,
	Andrei Emeltchenko <andrei.emeltchenko.news-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Herrmann <dh.herrmann-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1336499313.4320.4.camel-8upI4CBIZJIJvtFkdXX2HixXY32XiHfO@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, May 8, 2012 at 10:48 AM, Johannes Berg
<johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> wrote:
> On Tue, 2012-05-08 at 10:18 -0700, Joe Perches wrote:
>> On Tue, 2012-05-08 at 17:30 +0300, Andrei Emeltchenko wrote:
>> > On Tue, May 08, 2012 at 04:25:08PM +0200, Johannes Berg wrote:
>> > > On Tue, 2012-05-08 at 15:30 +0200, David Herrmann wrote:
>> > > > Hi Johannes
>> > > >
>> > > > On Mon, May 7, 2012 at 1:49 PM, Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> wrote:
>> > > > > Really? 2 static buffers that are used alternately based on a static
>> > > > > variable? How can that possibly be thread-safe? That may work in very
>> > > > > restricted scenarios, but ...
>> > > >
>> > > > Looking at "git blame" it seems the whole function is still from
>> > > > linux-2.4. Looks like no-one ever noticed. I've sent a patchset fixing
>> > > > it, thanks.
>> > >
>> > > I was thinking you could use %pM, but it seems BT addresses are stored
>> > > the wrong way around for some reason ...
>> >
>> > This looks like better idea then allocating buffers, we can use swap to
>> > take care about "wrong order".
>>
>> https://lkml.org/lkml/2010/12/3/358
>
> Pretty much what I had in mind, thanks. Luis, you'll notice that this
> will be a pain to backport in compat. :-)

Mumble grumble. Oh well! :) I'm starting to enjoy the curve balls.

  Luis
