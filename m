From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 3/4] bpf: add support for persistent maps/progs
Date: Fri, 16 Oct 2015 10:42:52 -0700
Message-ID: <5621371C.2000507@plumgrid.com>
References: <cover.1444956943.git.daniel@iogearbox.net>
 <ab1fceb2d68876d89bb2ebb3d2b45486d3cf2388.1444956943.git.daniel@iogearbox.net>
 <1445016105.1251655.412231129.6574D430@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: viro@ZenIV.linux.org.uk, ebiederm@xmission.com, tgraf@suug.ch,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexei Starovoitov <ast@kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445016105.1251655.412231129.6574D430@webmail.messagingengine.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/16/15 10:21 AM, Hannes Frederic Sowa wrote:
> Another question:
> Should multiple mount of the filesystem result in an empty fs (a new
> instance) or in one were one can see other ebpf-fs entities? I think
> Daniel wanted to already use the mountpoint as some kind of hierarchy
> delimiter. I would have used directories for that and multiple mounts
> would then have resulted in the same content of the filesystem. IMHO
> this would remove some ambiguity but then the question arises how this
> is handled in a namespaced environment. Was there some specific reason
> to do so?

That's an interesting question!
I think all mounts should be independent.
I can see tracing using one and networking using another one
with different hierarchies suitable for their own use cases.
What's an advantage to have the same content everywhere?
Feels harder to manage, since different users would need to
coordinate.
