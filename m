From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v4 2/2] bpf: remove struct bpf_map_type_list
Date: Tue, 11 Apr 2017 16:48:59 +0200
Message-ID: <58ECECDB.3000300@iogearbox.net>
References: <20170411133458.26816-1-johannes@sipsolutions.net> <20170411133458.26816-2-johannes@sipsolutions.net> <20170411144316.GB10662@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Johannes Berg <johannes.berg@intel.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41857 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751047AbdDKOtE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 10:49:04 -0400
In-Reply-To: <20170411144316.GB10662@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/11/2017 04:43 PM, Alexei Starovoitov wrote:
> On Tue, Apr 11, 2017 at 03:34:58PM +0200, Johannes Berg wrote:
>> From: Johannes Berg <johannes.berg@intel.com>
>>
>> There's no need to have struct bpf_map_type_list since
>> it just contains a list_head, the type, and the ops
>> pointer. Since the types are densely packed and not
>> actually dynamically registered, it's much easier and
>> smaller to have an array of type->ops pointer. Also
>> initialize this array statically to remove code needed
>> to initialize it.
>>
>> In order to save duplicating the list, move it to the
>> types header file added by the previous patch and
>> include it in the same fashion.
>>
>> Signed-off-by: Johannes Berg <johannes.berg@intel.com>
>> ---
>> v4: add ifdef on CONFIG_PERF_EVENTS for stack_map_ops
>
> I'm ok if you keep my ack after minor changes like this.
> Acked-by: Alexei Starovoitov <ast@kernel.org>

Me as well, thanks:

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
