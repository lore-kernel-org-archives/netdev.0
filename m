From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Patch: Make linkwatch more robust against rtnl holders
Date: Wed, 18 Feb 2004 20:18:26 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40340EE2.1010305@pobox.com>
References: <200402151511.49432.srompf@isg.de> <20040218171159.62e76670.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stefan Rompf <srompf@isg.de>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040218171159.62e76670.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Sun, 15 Feb 2004 15:11:47 +0100
> Stefan Rompf <srompf@isg.de> wrote:
> 
> 
>>the attached patch updates the linkwatch code so that it backs off and retries 
>>whenever it cannot get the rtnl semaphore.
> 
> 
> I think we should fix locking conflicts created by things like what
> the sungem driver is doing instead.


Agreed.

	Jeff
