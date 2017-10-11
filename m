From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 2/2] net sched act_vlan: VLAN action rewrite to
 use RCU lock/unlock and update
Date: Wed, 11 Oct 2017 08:28:24 -0400
Message-ID: <85746b06-ef33-d6f1-b831-8bbaee5b1b26@mojatatu.com>
References: <1507689219-22993-1-git-send-email-manish.kurup@verizon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: aring@mojatatu.com, mrv@mojatatu.com, manish.kurup@verizon.com
To: Manish Kurup <kurup.manish@gmail.com>, xiyou.wangcong@gmail.com,
        jiri@resnulli.us, davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507689219-22993-1-git-send-email-manish.kurup@verizon.com>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 17-10-10 10:33 PM, Manish Kurup wrote:
> Using a spinlock in the VLAN action causes performance issues when the VLAN
> action is used on multiple cores. Rewrote the VLAN action to use RCU read
> locking for reads and updates instead.
> 
> Signed-off-by: Manish Kurup <manish.kurup@verizon.com>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
