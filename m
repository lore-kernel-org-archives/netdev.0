From: "David S. Miller" <davem@davemloft.net>
Subject: Re: generic 802.11 stack
Date: Tue, 7 Sep 2004 12:10:19 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040907121019.733cc7aa.davem@davemloft.net>
References: <200408312111.02438.vda@port.imtp.ilyichevsk.odessa.ua>
	<200409072106.28334.vkondra@mail.ru>
	<20040907110813.6b463f3a.davem@davemloft.net>
	<200409072141.58893.vkondra@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Vladimir Kondratiev <vkondra@mail.ru>
In-Reply-To: <200409072141.58893.vkondra@mail.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 7 Sep 2004 21:41:54 +0300
Vladimir Kondratiev <vkondra@mail.ru> wrote:

> This should be done in generic way. This information used to communicate 
> berween particular driver and generic stack. For example, Rx PHY info and Tx 
> status info should be used for in-stack generic rate scaling algorithm.
> 
> To complicate it a bit, cb[] is only 48 bytes long. PHY info may easily exceed 
> this size, so it's better to allocate something and free it in destructor.
> 
> But again, point is this structure should be generic since it is used by 
> stack.

TCP does the same thing, and if space is an issue you can use
pointers in the cb[] area, other subsystems do this.
