From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [BUG][3.10.15] reading from /proc/sys/net/netfilter/nf_log/*
Date: Thu, 19 Dec 2013 10:09:48 +0800
Message-ID: <52B2556C.8090003@cn.fujitsu.com>
References: <20131214101042.5626c785@gandalf.local.home>	<52AEA3F6.2090508@cn.fujitsu.com>	<20131218155549.25c09718@gandalf.local.home>	<20131218210817.GC15863@breakpoint.cc> <20131218161139.2bb1538f@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Luis Claudio R. Goncalves" <lclaudio@uudg.org>,
	Clark Williams <williams@redhat.com>
To: Steven Rostedt <rostedt@goodmis.org>,
	Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:62299 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751210Ab3LSCeu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Dec 2013 21:34:50 -0500
In-Reply-To: <20131218161139.2bb1538f@gandalf.local.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/19/2013 05:11 AM, Steven Rostedt wrote:
> On Wed, 18 Dec 2013 22:08:17 +0100
> Florian Westphal <fw@strlen.de> wrote:
> 
>> Steven Rostedt <rostedt@goodmis.org> wrote:
>>> On Mon, 16 Dec 2013 14:55:50 +0800
>>> Gao feng <gaofeng@cn.fujitsu.com> wrote:
>>>> On 12/14/2013 11:10 PM, Steven Rostedt wrote:
>> [..]
>>>>> BUG: unable to handle kernel paging request at ffffffffa06189f0 
>>>>> IP: [<ffffffff814b7904>] nf_log_proc_dostring+0x94/0x1a0 
>> [..]
>>
>>>>> And after the module-load test, it crashes when reading those files.
>>>>>
>>>>
>>>> Oops, I forgot to unset the nf_loggers of net namespace when unload module nfnetlink_log.
>>>> I will send a patch, please have a try.
>>>
>>> Hi Gao,
>>>
>>> I haven't seen a patch. Was one sent?
>>
>> Yes, submitted to netfilter-devel, see http://patchwork.ozlabs.org/patch/301485/
> 
> Thanks, someone else pointed it to me on netdev list. I wasn't on the
> Cc, so I missed it.
> 

Sorry, I thought git send-mail will send the patch to the Reported-by.
but now I know, it didn't. :(
