From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 1/2] bpf: remove struct bpf_prog_type_list
Date: Tue, 04 Apr 2017 19:32:30 +0200
Message-ID: <1491327150.26929.3.camel@sipsolutions.net>
References: <20170404172711.4088-1-johannes@sipsolutions.net>
         (sfid-20170404_192734_554753_EB507E8D)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:37854 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754468AbdDDRcf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Apr 2017 13:32:35 -0400
In-Reply-To: <20170404172711.4088-1-johannes@sipsolutions.net> (sfid-20170404_192734_554753_EB507E8D)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oops, I really meant to send these as RFC more than anything, because I
don't really understand why it's done that way :)

FWIW, the bloat-o-meter looks similar in both cases, like this:

add/remove: 0/11 grow/shrink: 9/1 up/down: 145/-365 (-220)
function                                     old     new   delta
bpf_map_types                                 16      96     +80
register_htab_map                             56      76     +20
register_array_map                            32      42     +10
bpf_register_map_type                         35      45     +10
register_trie_map                             20      25      +5
register_stack_map                            20      25      +5
register_prog_array_map                       20      25      +5
register_perf_event_array_map                 20      25      +5
register_cgroup_array_map                     20      25      +5
sys_bpf                                     1140    1127     -13
trie_type                                     32       -     -32
stack_map_type                                32       -     -32
prog_array_type                               32       -     -32
perf_event_array_type                         32       -     -32
percpu_array_type                             32       -     -32
htab_type                                     32       -     -32
htab_percpu_type                              32       -     -32
htab_lru_type                                 32       -     -32
htab_lru_percpu_type                          32       -     -32
cgroup_array_type                             32       -     -32
array_type                                    32       -     -32

johannes
