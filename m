From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2] unix: properly account for FDs passed over unix
 sockets
Date: Wed, 3 Feb 2016 02:12:55 +0100
Message-ID: <56B15417.6080002@stressinduktion.org>
References: <201601100657.u0A6vk1B025554@mail.home.local>
 <CANq1E4T0sqTTD4RsWXTUrFvsKvEsKsUiPbskWd=wAEVu83_Srg@mail.gmail.com>
 <56B0F574.5080105@stressinduktion.org>
 <CA+55aFw2AwsWbvwp6f8H+eExt_CMfh7VA3od6hto_M0hg9z3Tg@mail.gmail.com>
 <56B11278.8000805@stressinduktion.org> <20160202203929.GC25828@1wt.eu>
 <56B125B7.6020702@stressinduktion.org>
 <CA+55aFzqdR80MKupCs+va8vtbTU67Jobax1QAbfWNktQCXFxpA@mail.gmail.com>
 <56B15067.6000407@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev@vger.kernel.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Simon McVittie <simon.mcvittie@collabora.co.uk>,
	Willy Tarreau <w@1wt.eu>, Eric Dumazet <edumazet@google.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	???????? ?????????????????? <socketpair@gmail.com>,
	David Herrmann <dh.herrmann@gmail.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56B15067.6000407@stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03.02.2016 01:57, Hannes Frederic Sowa wrote:
> On 02.02.2016 23:11, Linus Torvalds wrote:
>> But I'm OK with that patch as is if you prefer it that way (maybe you
>> want
>> to use the cred to then test for root separately etc, out maybe there
>> already was done use of cred as cred that I just missed when reading the
>> patch on my phone..)
>
> I don't see any reason to switch over to struct user_struct. I tested a
> patch and will send it out soon.

I meant that there is no reason not to switch over to struct 
user_struct. Patch is send out.

Thanks for looking into this!

Hannes
