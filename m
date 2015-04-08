From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH iproute2 -next] tc, bpf: finalize eBPF support for cls
 and act front-end
Date: Wed, 08 Apr 2015 07:58:26 -0400
Message-ID: <552517E2.2070709@mojatatu.com>
References: <d9a577418790f99130c1cb20dc01cf50c2d6a7da.1427754287.git.daniel@iogearbox.net> <551BE636.7040505@mojatatu.com> <551BFD00.1090303@iogearbox.net> <20150401223044.GB19425@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, ast@plumgrid.com, jiri@resnulli.us,
	netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>, Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:36548 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751641AbbDHL62 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 07:58:28 -0400
Received: by iebrs15 with SMTP id rs15so71571504ieb.3
        for <netdev@vger.kernel.org>; Wed, 08 Apr 2015 04:58:28 -0700 (PDT)
In-Reply-To: <20150401223044.GB19425@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Maybe i should be reading backwards;-> But i skipped a few emails
instead.

On 04/01/15 18:30, Thomas Graf wrote:
> On 04/01/15 at 04:13pm, Daniel Borkmann wrote:

>> I see it as a way to offer a generic, fast and 'safe' option for
>> classifier and action developers to have a programmable data path
>> in the traffic control subsystem in the kernel, which I think is
>> very powerful and important in various use-cases. I regard it as
>> a similar way and elegant solution as tcpdump or nftables resolve
>> their problems internally, in other words, to provide a _generic_
>> solution to address _specific, customized_ issues. Perhaps an anti
>> feature-bloat, if you will. ;) My viewpoint is that this ties well
>> together into the kernel landscape, and also makes us improve
>> various other subsystems that it makes use of, successively.
>
> Alexei will remember that I gave him a hard time with the exact
> same remarks as Jamal brought up when he presented this in New
> Orleans ;-)
>

I think you hit on my concern. The potential of another frankestein
exists here.

> What turned my viewpoint around was the knowledge that function
> calls are limited. eBPF programs can only make calls to functions
> which have been specifically whitelisted for eBPF programs. This
> policy is enforced by the kernel through the verifier. Exported
> symbols are not automatically whitelisted. So an eBPF program
> can't call into drivers or use arbitrary kernel APIs and is thus
> a lot more restricted than a kernel module.
>

I havent seen much restriction in the sample code posted by Daniel.
Dont get me wrong, I like ebpf (when ovs was being presented i didnt
say I liked it, but if you recall did protest the frankestein factor).

cheers,
jamal
