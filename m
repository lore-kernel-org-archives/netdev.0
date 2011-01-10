From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] Cleanup include/net/tcp.h include-files and coding-style
Date: Mon, 10 Jan 2011 13:11:21 +0200
Message-ID: <AANLkTik7mug7j=VLz80DX_hJokeO3=ie+KRcMViSL4kB@mail.gmail.com>
References: <1294606534-28522-1-git-send-email-christoph.paasch@uclouvain.be>
	<201101092232.19171.christoph.paasch@uclouvain.be>
	<1294610141.2823.31.camel@localhost>
	<201101092333.19406.christoph.paasch@uclouvain.be>
	<1294614389.2823.35.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: christoph.paasch@uclouvain.be, Randy Dunlap <rdunlap@xenotime.net>,
	davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:56066 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750982Ab1AJLLX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jan 2011 06:11:23 -0500
In-Reply-To: <1294614389.2823.35.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 10, 2011 at 1:06 AM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> On Sun, 2011-01-09 at 23:33 +0100, Christoph Paasch wrote:

>> > If a file directly references definitions that are supposed to be
>> > provided by a certain header, changing it to rely on indirect inclusion
>> > of that header generally does *not* aid maintenance.
>> But then, to be coherent, we would need to add the following includes (and I'm
>> even not 100% sure if it's all we need):
>>
>> linux/percpu_counter.h (needed for percpu_counter_sum_positive)
>
> Yes.

Currently code compiles fine, so necessary headers are in place,
so simply adding new headers doesn't help anything.

>> linux/mm_types.h (needed for struct page)
>> linux/aio.h (needed for struct kiocb)
>> net/inet_sock.h (needed for struct ip_options)
>> linux/pipe_fs_i.h (needed for struct pipe_inode_info)
>> linux/poll.h (needed for struct poll_table_struct)
>
> Or declarations of those structs.
>
>> linux/compiler.h (needed for __percpu)
> [...]
>
> Yes.
