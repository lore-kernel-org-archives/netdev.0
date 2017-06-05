From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] net: sched: fix mips build failure
Date: Mon, 5 Jun 2017 06:50:04 +0200
Message-ID: <20170605045004.GA1929@nanopsycho.orion>
References: <1496612653-12419-1-git-send-email-sudipm.mukherjee@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Ralf Baechle <ralf@linux-mips.org>,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-mips@linux-mips.org
To: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1496612653-12419-1-git-send-email-sudipm.mukherjee@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sun, Jun 04, 2017 at 11:44:13PM CEST, sudipm.mukherjee@gmail.com wrote:
>The build of mips ar7_defconfig was failing with the error:
>../net/sched/act_api.c: In function 'tcf_action_goto_chain_init':
>../net/sched/act_api.c:37:18: error:
>	implicit declaration of function 'tcf_chain_get'
>	[-Werror=implicit-function-declaration]
>
>../net/sched/act_api.c: In function 'tcf_action_goto_chain_fini':
>../net/sched/act_api.c:45:2: error:
>	implicit declaration of function 'tcf_chain_put'
>	[-Werror=implicit-function-declaration]
>
>Add two inline helpers for the case where CONFIG_NET_CLS is not enabled.
>
>Signed-off-by: Sudip Mukherjee <sudipm.mukherjee@gmail.com>

I already sent a fix for this:

http://patchwork.ozlabs.org/project/netdev/list/
