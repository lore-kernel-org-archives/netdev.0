From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 3/4] bpf: add support for persistent maps/progs
Date: Thu, 22 Oct 2015 15:22:43 +0200
Message-ID: <5628E323.1010808@iogearbox.net>
References: <1445280385.602530.414418777.63627F89@webmail.messagingengine.com> <562545AA.2080207@plumgrid.com> <1445284997.621186.414538017.6E35B341@webmail.messagingengine.com> <56255714.2070800@plumgrid.com> <56256BF9.1090500@iogearbox.net> <56258B11.9080505@plumgrid.com> <5625FF71.8020304@iogearbox.net> <56267FAF.60206@plumgrid.com> <87io61fjx3.fsf@x220.int.ebiederm.org> <5627AC79.5000704@iogearbox.net> <20151021183447.GC23554@pox.localdomain> <56281555.3030504@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	davem@davemloft.net, viro@ZenIV.linux.org.uk,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexei Starovoitov <ast@kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>, Thomas Graf <tgraf@suug.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56281555.3030504@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/22/2015 12:44 AM, Alexei Starovoitov wrote:
...
> all users) When you have to hack drivers/base/core.c to get there it
> should have been a warning sign that something is wrong with
> this cdev approach.

Hmm, you know, this had nothing to do with it, merely to save ~20 LoC
that I can do just as well inside BPF framework. No changes in driver
API needed.

>> I've read the discussion passively and my take away is that, frankly,
>> I think the differences are somewhat minor. Both architectures can
>> scale to what we need. Both will do the job. I'm slightly worried about
>> exposing uAPI as a FS, I think that didn't work too well for sysfs. It's
>> pretty much a define the format once and never touch it again kind of
>> deal.
>
> It's even worse in cdev style since it piggy backs on sysfs.

I don't mind with what approach we're going in the end, but this kind
of discussion is really tiring, and not going anywhere.

Lets just make a beer call, so we can hash out a way forward that works
for everyone.

On that note: cheers! ;)
Daniel
