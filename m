From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v8 tip 5/9] tracing: allow BPF programs to call bpf_trace_printk()
Date: Fri, 20 Mar 2015 14:44:21 -0700
Message-ID: <550C94B5.80301@plumgrid.com>
References: <1426816787-5001-1-git-send-email-ast@plumgrid.com>	<1426816787-5001-6-git-send-email-ast@plumgrid.com> <20150320172219.45ff7157@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@kernel.org>, Namhyung Kim <namhyung@kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	linux-api@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:35648 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751380AbbCTVoY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 17:44:24 -0400
Received: by pagj4 with SMTP id j4so29665328pag.2
        for <netdev@vger.kernel.org>; Fri, 20 Mar 2015 14:44:23 -0700 (PDT)
In-Reply-To: <20150320172219.45ff7157@gandalf.local.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/20/15 2:22 PM, Steven Rostedt wrote:
>> +/* limited trace_printk()
>> + * only %d %u %x %ld %lu %lx %lld %llu %llx %p conversion specifiers allowed
>> + */
>
> Ah! Again, don't contaminate the rest of the kernel with net comment
> styles! :-)

ok :)

>> +		} else if (fmt[i] == 'p') {
>> +			mod[fmt_cnt]++;
>> +			i++;
>> +			if (!isspace(fmt[i]) && fmt[i] != 0)
>
> I wonder if we should allow punctuation here too? None alpha-numeric
> characters?

yes. just checked all of ispunct characters after %p.
All should be fine.

Thanks!
