From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 3/4] bpf: add support for persistent maps/progs
Date: Fri, 16 Oct 2015 19:43:08 -0700
Message-ID: <5621B5BC.8020204@plumgrid.com>
References: <cover.1444956943.git.daniel@iogearbox.net>
 <ab1fceb2d68876d89bb2ebb3d2b45486d3cf2388.1444956943.git.daniel@iogearbox.net>
 <1445016105.1251655.412231129.6574D430@webmail.messagingengine.com>
 <5621371C.2000507@plumgrid.com> <56213A61.40509@iogearbox.net>
 <87d1welkp8.fsf@x220.int.ebiederm.org> <56214FAC.5060704@plumgrid.com>
 <87y4f2io9l.fsf@x220.int.ebiederm.org> <5621649A.80403@plumgrid.com>
 <87mvviidku.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	davem@davemloft.net, viro@ZenIV.linux.org.uk, tgraf@suug.ch,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexei Starovoitov <ast@kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35310 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752040AbbJQCnK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 22:43:10 -0400
Received: by payp3 with SMTP id p3so5345464pay.2
        for <netdev@vger.kernel.org>; Fri, 16 Oct 2015 19:43:10 -0700 (PDT)
In-Reply-To: <87mvviidku.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/16/15 4:44 PM, Eric W. Biederman wrote:
> Alexei Starovoitov <ast@plumgrid.com> writes:
>
>> We can argue about api for 2nd, whether it's mount with fd=1234 string
>> or else, but for the first mount style doesn't make sense.
>
> Why does mount not make sense?  It is exactly what you are looking for
> so why does it not make sense?

hmm, how do you get a new fd back after mounting it?
Note, open cannot be overloaded, so we end up with BPF_NEW_FD anyway,
but now it's more convoluted and empty mounts are everywhere.
