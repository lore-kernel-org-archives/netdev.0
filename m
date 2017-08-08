From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 2/2] bpf: Initialise mod[] in bpf_trace_printk
Date: Tue, 08 Aug 2017 14:54:33 -0700 (PDT)
Message-ID: <20170808.145433.1287676484744976417.davem@davemloft.net>
References: <59897A7C.10009@iogearbox.net>
        <20170808.094857.245786887664041622.davem@davemloft.net>
        <650EB3B0-1101-4624-905A-E68D2EC5920F@imgtec.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, ast@kernel.org, linux-kernel@vger.kernel.org,
        rostedt@goodmis.org, mingo@redhat.com, netdev@vger.kernel.org
To: james.hogan@imgtec.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <650EB3B0-1101-4624-905A-E68D2EC5920F@imgtec.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Hogan <james.hogan@imgtec.com>
Date: Tue, 08 Aug 2017 22:20:05 +0100

> cool, i hadn't realised unmentioned elements in an initialiser are
> always zeroed, even when non-global/static, so had interpreted the
> whole array as uninitialised. learn something new every day :-)
> sorry for the noise.

You didn't have to know in the first place, you could have simply
compiled the code into assembler by running:

	make kernel/trace/bpf_trace.s

and seen for yourself before putting all of this time and effort into
this patch and discussion.

If you don't know what the compiler does, simply look!
