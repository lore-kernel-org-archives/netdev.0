From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v10 tip 5/9] tracing: allow BPF programs to call
 bpf_trace_printk()
Date: Mon, 23 Mar 2015 11:37:57 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB07731@AcuExch.aculab.com>
References: <1427053150-32213-1-git-send-email-ast@plumgrid.com>
 <1427053150-32213-6-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Steven Rostedt <rostedt@goodmis.org>,
	Namhyung Kim <namhyung@kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"linux-api@vger.kernel.org" <linux-api@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: 'Alexei Starovoitov' <ast@plumgrid.com>,
	Ingo Molnar <mingo@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.185]:55991 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752028AbbCWLjg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 07:39:36 -0400
In-Reply-To: <1427053150-32213-6-git-send-email-ast@plumgrid.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov
> Debugging of BPF programs needs some form of printk from the program,
> so let programs call limited trace_printk() with %d %u %x %p modifiers only.

Should anyone be allowed to use BPF programs to determine the kernel
addresses of any items?
Looks as though it is leaking kernel addresses to userspace.
Note that the problem is with the arguments, not the format string.

	David
