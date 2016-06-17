From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [iproute PATCH 1/3] Use C99 style initializers everywhere
Date: Fri, 17 Jun 2016 22:36:07 +0200
Message-ID: <57645F37.5010100@iogearbox.net>
References: <1466178968-27439-1-git-send-email-phil@nwl.cc> <1466178968-27439-2-git-send-email-phil@nwl.cc> <ddef688e6e3f4a1a895880de1f9f069d@HQ1WP-EXMB11.corp.brocade.com> <20160617093401.24ae66b1@xeon-e3> <5764295E.7070103@iogearbox.net> <9e1c05c7b4894137a80bdb3d2a361bbc@HQ1WP-EXMB11.corp.brocade.com> <20160617115753.6205562d@xeon-e3> <d122479b-f5cb-2dce-b0ba-d28f3254db32@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Phil Sutter <phil@nwl.cc>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"julien.floret@6wind.com" <julien.floret@6wind.com>
To: David Ahern <dsa@cumulusnetworks.com>,
	Stephen Hemminger <shemming@brocade.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:54637 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752796AbcFQUgM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2016 16:36:12 -0400
In-Reply-To: <d122479b-f5cb-2dce-b0ba-d28f3254db32@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/17/2016 10:15 PM, David Ahern wrote:
> On 6/17/16 12:57 PM, Stephen Hemminger wrote:
>> On Fri, 17 Jun 2016 16:58:14 +0000
>> Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:
>>> Le 17/06/2016 18:46, Daniel Borkmann a =C3=A9crit :
>>>> On 06/17/2016 06:34 PM, Stephen Hemminger wrote:
>>>>> On Fri, 17 Jun 2016 16:09:20 +0000
>>>>> Daniel Borkmann <daniel@iogearbox.net> wrote:
>>>>>
>>>>>> Please have a look at commit 8f80d450c3cb ("tc: fix compilation =
with old gcc
>>>>>> (< 4.6)") ...
>>>>>>
>>>>>> Your changes effectively revert them again. Here, and some other=
 parts of the
>>>>>> bpf frontend
>>>>>> code bits.
>>>>>
>>>>> GCC 4.6 is 3 years old. So perhaps it is time to move on.
>>>>> Maybe add a GCC version check in the makefile, to fail cleanly.
>>>>
>>>> Well, you don't have to ask me but rather the patch submitters (Cc=
).
>>>>
>>>> I haven't used RHEL in quite a while, but I could imagine it might
>>>> be related to built it there perhaps.
>>> Yes. For some specific arch, we have only old toolchains.
>>>
>>> The rule was always to be backward compatible with old kernels. It =
implies to
>>> also support the compilation with old toolchains ;-)
>>
>> It makes sense that if you can build a kernel with old toolchain, th=
at
>> iproute2 needs to be buildable as well.
>>
>> The current kernels are documented to require 3.2 or later.
>
> Daniel's patch mentions anonymous structs so naming them should be fi=
ne.
>
> Daniel: What OS were you using with the 4.6 gcc? I lost my range of O=
S VMs when I changed employers last year. At this point I don't recall =
which OS uses < 4.6.

Once again, you have to ask Nicolas or Julien for their RHEL version,
not me ... please have a look at 8f80d450c3cb. ;)

I just pointed to the fact that this would basically undo their changes
that they've submitted some time ago to the BPF frontend, reintroducing
the issue for them. Unfortunately, the anonymous struct cannot be named
due to uapi reasons. It should have been named from the very beginning,
but unfortunately too late now. So I would suggest to just leave those
affected parts as is.

Thanks,
Daniel
