From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: Re: Ethernet drivers wiki page
Date: Sat, 5 Jun 2010 15:54:25 -0700
Message-ID: <AANLkTin1s5HCp795WwAgvMbC0PWK0cv7CBmCmY_D3EOW@mail.gmail.com>
References: <AANLkTinSjJsqNvEhJZIE6cJxEkBtg-DO2dqZWMczUy2i@mail.gmail.com>
	<AANLkTik1isTBolg4IDchOlmKqXOLjQoobZrJ-9bb8ZL5@mail.gmail.com>
	<20100604152324.1fa28f2f@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, "H. Peter Anvin" <hpa@kernel.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	linux-kernel@vger.kernel.org,
	"Luis R. Rodriguez" <mcgrof@gmail.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100604152324.1fa28f2f@nehalam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 4, 2010 at 3:23 PM, Stephen Hemminger <shemminger@vyatta.com> wrote:
> On Fri, 4 Jun 2010 15:04:17 -0700
> "Luis R. Rodriguez" <mcgrof@gmail.com> wrote:
>
>> On Fri, Jun 4, 2010 at 2:52 PM, Luis R. Rodriguez <mcgrof@gmail.com> wrote:
>> > Where can I start adding documentation for our Ethernet drivers
>> > upstream? I was hoping for a wiki but I don't think we have a netdev
>> > one yet. Shall we create one or piggy back on something else? I'm
>> > reviewing:
>> >
>> > https://wiki.kernel.org/
>> >
>> > FWIW, I want to see something like this:
>> >
>> > http://wireless.kernel.org/en/users/Drivers
>> >
>> > But for ethernet.
>>
>> Since I've stuffed a few ethernet drivers on compat-wireless I might
>> as well start carrying more. So now we'd have 802.11, Bluetooth and
>> Ethernet all backported using the same framework, automatically, down
>> to at least the oldest stable kernel supported listed on kernel.org
>> and using all a generic compat module.
>>
>> I want to document all this crap.
>
> Why not Documentation/networking in kernel source?

I think a wiki works better for this sort of documentation, the
documentation I intend on writing is for end users, not developers.
Users tend to also search on google, not the kernel source.

> There is already documentation there though much of it is out of date.

I think its because a git tree works well for code, but not for
documentation. Technically I'm even an advocate for developer
documentation on wikis too though.

> This has the advantage of having change log and matching kernel version.

With Ethernet I'd just stuff all new drivers into the wiki as they go
into linux-next, after all the drivers would be available immediately
even for use on older kernels, so the information would be up to date,
we could just annotate as per what kernel release what feature went or
what chipsets were supported. For example, see:

http://wireless.kernel.org/en/users/Drivers/ath9k#supported_chipsets

  Luis
