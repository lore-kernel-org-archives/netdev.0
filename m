From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] ibmtr - get rid of MOD_INC/DEC
Date: Fri, 15 Aug 2003 09:30:05 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F3CE05D.5080306@pobox.com>
References: <20030813174658.2c5125af.shemminger@osdl.org> <20030814205747.5fcd83d0.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, mikep@linuxtr.net,
   linux-tr@linuxtr.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030814205747.5fcd83d0.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Wed, 13 Aug 2003 17:46:58 -0700
> Stephen Hemminger <shemminger@osdl.org> wrote:
> 
> 
>>With the new module system MOD_INC/MOD_DEC are no longer necessary.
>>Also changed to new module init/exit macros for function setup.
>>
>>The module exit code can sleep, so calling schedule_timeout is better
>>than spinning.
> 
> 
> Can't we lose the MODULE ifdefs too?


Doubtful for ibmtr, which requires some of them for ibmtr_cs (which 
#includes it).

	Jeff
