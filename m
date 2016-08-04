From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC 2/4] bpf, security: Add Checmate
Date: Thu, 04 Aug 2016 10:28:22 +0200
Message-ID: <1470299302.13693.13.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160804071140.GA19121@ircssh.c.rugged-nimbus-611.internal>
	 <CAD=hENfPUmP6odm+oFg0gAEJ5oqKksTyZPYE1F1iXJW=DS7sqQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sargun Dhillon <sargun@sargun.me>,
	LKML <linux-kernel@vger.kernel.org>,
	alexei.starovoitov@gmail.com, daniel@iogearbox.net,
	linux-security-module@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: zhuyj <zyjzyj2000@gmail.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <CAD=hENfPUmP6odm+oFg0gAEJ5oqKksTyZPYE1F1iXJW=DS7sqQ@mail.gmail.com>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please do not top post

On Thu, 2016-08-04 at 16:08 +0800, zhuyj wrote:
>  +void register_checmate_prog_ops(void);
> maybe it is extern void register_checmate_prog_ops(void);?
> 
> +       preempt_disable();
> +       rcu_read_lock();
> IMHO, it is not necessary to use the above 2 since rcu_read_lock will
> call preempt_disable.

You might double check if this claim is true if CONFIG_PREEMPT_RCU=y



