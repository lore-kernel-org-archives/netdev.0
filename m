From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] bpf: add show_fdinfo handler for maps
Date: Thu, 19 Nov 2015 19:36:10 +0100
Message-ID: <564E169A.6070506@iogearbox.net>
References: <b3f1dd7e21d72dc47beac222d655640ee584c5cd.1447930253.git.daniel@iogearbox.net> <1447957164.2292053.444566657.27F336C7@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:46969 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934543AbbKSSgP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 13:36:15 -0500
In-Reply-To: <1447957164.2292053.444566657.27F336C7@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/19/2015 07:19 PM, Hannes Frederic Sowa wrote:
> On Thu, Nov 19, 2015, at 11:56, Daniel Borkmann wrote:
>> Add a handler for show_fdinfo() to be used by the anon-inodes
>> backend for eBPF maps, and dump the map specification there. Not
>> only useful for admins, but also it provides a minimal way to
>> compare specs from ELF vs pinned object.
>>
>> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
>
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>
> Does it make sense to include bpf_htab->count in case of a hashmap?

It would give a sort-of only volatile view, e.g. like the map's
refcount. It would be possible to show it, but only as kind of
informative to an admin, have no strong opinion on it, though.

I think this goes rather into the direction of better debugging
interfaces for eBPF, probably makes sense think about it wrt a
general debugging/introspection framework and better dump it
there ...
