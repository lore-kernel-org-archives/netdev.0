From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 2/6] test_bpf: allow tests to specify an skb fragment.
Date: Mon, 03 Aug 2015 19:37:34 +0200
Message-ID: <55BFA6DE.7040108@iogearbox.net>
References: <1438610528-14245-1-git-send-email-nschichan@freebox.fr> <1438610528-14245-3-git-send-email-nschichan@freebox.fr> <55BF88E4.2050307@iogearbox.net> <55BF9909.4070704@freebox.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Nicolas Schichan <nschichan@freebox.fr>,
	Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55BF9909.4070704@freebox.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/03/2015 06:38 PM, Nicolas Schichan wrote:
> On 08/03/2015 05:29 PM, Daniel Borkmann wrote:
>> On 08/03/2015 04:02 PM, Nicolas Schichan wrote:
>> We now have 286 tests, which is awesome!
>>
>> Perhaps, we need to start thinking of a better test description method
>> soonish as the test_bpf.ko module grew to ~1.6M, i.e. whenever we add
>> to struct bpf_test, it adds memory overhead upon all test cases.
>
> Indeed, test_bpf.ko is turning quite large (1.4M when compiled for ARM).
>
> It looks like gzip is able to do wonders on the module though as I end up with
> a 94.7K test_bpf.ko.gz file and if the modutils are compiled with
> --enable-zlib, it will be gunziped automatically before being loaded to the
> kernel.

I think it just contains a lot of zero blocks, which then compress nicely.

> I think that marking tests[] array as __initdata will help with the runtime
> memory use if someone forgets to rmmod the test_bpf module after a completely
> successful run.

Can be done, too, yep. Do you want to send a patch? ;)
