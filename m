From: Andrew Morton <akpm@osdl.org>
Subject: Re: Fw: [Bugme-new] [Bug 4628] New: Test server hang while running
 rhr (network) test on RHEL4 with kernel 2.6.12-rc1-mm4
Date: Thu, 26 May 2005 18:44:36 -0700
Message-ID: <20050526184436.161a6af0.akpm@osdl.org>
References: <468F3FDA28AA87429AD807992E22D07E056F70D4@orsmsx408>
	<20050527012626.GA17294@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ganesh.venkatesan@intel.com, ganesh.venkatesan@gmail.com,
        hejianj@cn.ibm.com, anton@samba.org, rende@cn.ibm.com,
        jesse.brandeburg@intel.com, jgarzik@pobox.com, wangjs@cn.ibm.com,
        john.ronciak@intel.com, cdlwangl@cn.ibm.com,
        linuxppc64-dev@lists.linuxppc.org.sgi.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050527012626.GA17294@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu <herbert@gondor.apana.org.au> wrote:
>
>  On Thu, May 26, 2005 at 05:28:55PM -0700, Venkatesan, Ganesh wrote:
>  > Would adding flush_sheduled_tasks() to e100_down, do it?
> 
>  Even though it might be OK it's probably not a good idea to have
>  the task flush itself while it's running.

flush_workqueue() handles that case.
