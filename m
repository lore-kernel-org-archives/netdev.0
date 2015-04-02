From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH iproute2 -next] tc, bpf: finalize eBPF support for cls
 and act front-end
Date: Thu, 02 Apr 2015 02:24:13 +0200
Message-ID: <551C8C2D.5060504@iogearbox.net>
References: <d9a577418790f99130c1cb20dc01cf50c2d6a7da.1427754287.git.daniel@iogearbox.net> <1427933636.1888890.248325033.0A76BE0D@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, jiri@resnulli.us, tgraf@suug.ch,
	netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:47067 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751576AbbDBAYY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 20:24:24 -0400
In-Reply-To: <1427933636.1888890.248325033.0A76BE0D@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Hannes,

On 04/02/2015 02:13 AM, Hannes Frederic Sowa wrote:
...
> Maybe a small utility programs like:
>
> bpf (--lookup|--update|--delete|--get-next-key) -fd
> filedescriptor-number (type conversion parameters here) key [value]
>
> So it can be easily used by shell scripts.
>
> For that the filedescriptor numbers would need to be exported (already
> opened) into a spawned shell and the numbers could be specified either
> in environment or just by printing text which can be sourced by shells
> (we already talked about the maybe exec 5</proc/pid/fd/1234 idea). Seems
> this can be just build ontop this current patch by extending the
> bpf-agent you already build, no?

I was thinking about that and trying it out, but as far as I can tell,
due to the anon inodes that are currently underlying as the fd provider,
it doesn't work w/o larger kernel changes. So, the file descriptor passing
is currently the only way to transfer control.

Cheers,
Daniel
