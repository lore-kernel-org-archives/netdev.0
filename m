From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: iproute2: missing patches in branch net-next
Date: Thu, 28 May 2015 18:32:32 +0200
Message-ID: <55674320.2030002@iogearbox.net>
References: <5566FC7C.1000200@6wind.com> <20150528091949.6cabe893@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@redhat.com>, Jiri Pirko <jiri@resnulli.us>,
	David Ward <david.ward@ll.mit.edu>,
	Jonathan Toppins <jtoppins@cumulusnetworks.com>,
	Eric Dumazet <edumazet@google.com>
To: Stephen Hemminger <stephen@networkplumber.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:39194 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751556AbbE1Qcp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 12:32:45 -0400
In-Reply-To: <20150528091949.6cabe893@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/28/2015 06:19 PM, Stephen Hemminger wrote:
> On Thu, 28 May 2015 13:31:08 +0200
> Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:
>
>> Hi Stephen,
>>
>> some patches that were recently included in iproute2 branch net-next are not
>> visible anymore on kernel.org. It seems that the branch has been overridden
>> (note the "forced update" when I've fetched it):
>>
>> $ git fetch
>> remote: Counting objects: 65, done.
>> remote: Compressing objects: 100% (65/65), done.
>> remote: Total 65 (delta 58), reused 0 (delta 0)
>> Unpacking objects: 100% (65/65), done.
>>   From git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2
>>    + aacee2695a90...eb9d6e794b52 net-next   -> origin/net-next  (forced update)
>>      f043759dd492..c52827e9077f  master     -> origin/master
>>
>>
>> The following patches are lost:
>> aacee2695a90 tc: gred: Add support for TCA_GRED_LIMIT attribute
>> b6ec53e3008a xfrmmonitor: allows to monitor in several netns
>> 449b824ad196 ipmonitor: allows to monitor in several netns
>> 3b0006f8183e ipmonitor: introduce print_headers
>> 0628cddd9d5c libnetlink: introduce rtnl_listen_filter_t
>> 2503247d58c3 man: update ip monitor page
>> 6fc1f8add30b iplink_bond: add support for ad_actor and port_key options
>> df1c7d9138ea codel: add ce_threshold support to codel & fc_codel
>> 30eb304ecd1d tc: add support for Flower classifier
>> 1a4dda7103bc ss: add support for bytes_acked & bytes_received
>> 908755dc49df iproute2: GENEVE support
>> f9b004020a89 Merge branch 'master' into net-next
>> 8f42ceaf2491 Update kernels for net-next
>>
>>
>> Regards,
>> Nicolas
>
> Ah found it was botched merge. The commits were still there locally.
> Should be fixed now, but had to force back to known good state on net-next branch.

Okay, but now the iproute2 -next patches from last days are gone,
right? I noticed the tc man page bits applied from yesterday are
not in the -next tree anymore. Do you re-push those on top of the
current restored state?

Thanks,
Daniel
