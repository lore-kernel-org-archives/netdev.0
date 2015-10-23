From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 3/4] bpf: add support for persistent maps/progs
Date: Fri, 23 Oct 2015 15:47:56 +0200
Message-ID: <562A3A8C.1060705@iogearbox.net>
References: <cover.1444956943.git.daniel@iogearbox.net>	<562301F9.1030702@plumgrid.com> <5623B4B4.2010703@iogearbox.net>	<5623CD8D.7000500@iogearbox.net> <56240814.8020105@plumgrid.com>	<1445240171.3728424.413797809.230D716F@webmail.messagingengine.com>	<5624BD0C.3070404@iogearbox.net> <5624FCDF.3090601@iogearbox.net>	<562518B8.2070401@plumgrid.com> <56252A43.3000706@iogearbox.net>	<56253335.9000206@plumgrid.com>	<1445280385.602530.414418777.63627F89@webmail.messagingengine.com>	<562545AA.2080207@plumgrid.com>	<1445284997.621186.414538017.6E35B341@webmail.messagingengine.com>	<56255714.2070800@plumgrid.com> <56256BF9.1090500@iogearbox.net>	<56258B11.9080505@plumgrid.com> <5625FF71.8020304@iogearbox.net>	<56267FAF.60206@plumgrid.com> <87io61fjx3.fsf@x220.int.ebiederm.org>	<5627AC79.5000704@
 iogearbox.net> <87a8rabsst.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	davem@davemloft.net, viro@ZenIV.linux.org.uk, tgraf@suug.ch,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexei Starovoitov <ast@kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87a8rabsst.fsf@x220.int.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/22/2015 09:35 PM, Eric W. Biederman wrote:
> Daniel Borkmann <daniel@iogearbox.net> writes:
>> On 10/20/2015 08:56 PM, Eric W. Biederman wrote:
>> ...
>>> Just FYI:  Using a device for this kind of interface is pretty
>>> much a non-starter as that quickly gets you into situations where
>>> things do not work in containers.  If someone gets a version of device
>>> namespaces past GregKH it might be up for discussion to use character
>>> devices.
>>
>> Okay, you are referring to this discussion here:
>>
>>    http://thread.gmane.org/gmane.linux.kernel.containers/26760
>
> That is a piece of it.  It is an old old discussion (which generally has
> been handled poorly).  For the forseeable future device namespaces have
> a firm NACK by GregKH.  Which means that dynamic character device based
> interfaces do not work in containers.  Which means if you are not
> talking about physical hardware, character devices are a poor fit.

Yes, it breaks down with real namespace support. Reworking the set with
an improved version of the fs code is already in progress.

Thanks,
Daniel
