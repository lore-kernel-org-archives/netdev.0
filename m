From: Andi Kleen <ak@suse.de>
Subject: Re: in-driver QoS
Date: Tue, 8 Jun 2004 00:59:23 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040608005923.408ddf21.ak@suse.de>
References: <200406062128.47070.vkondra@mail.ru>
	<20040607140011.GC28639@wotan.suse.de>
	<200406072335.04125.vkondra@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Vladimir Kondratiev <vkondra@mail.ru>
In-Reply-To: <200406072335.04125.vkondra@mail.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 7 Jun 2004 23:35:04 +0300
Vladimir Kondratiev <vkondra@mail.ru> wrote:

> How could I use these multiple qdiscs? If I use existing driver framework, I 
> have hard_start_xmit, that represent single queue. Do you have any examples 
> how driver can access qdiscs directly? I.e. I have 4 queues in the driver, I 
> want to fill it separately, start/stop incoming queues from stack etc.

Normally it would be configured by the user tools (using tc) 


-Andi
