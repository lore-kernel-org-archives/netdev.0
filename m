From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: PATCH: netpoll with xircom_cb
Date: Thu, 14 Oct 2004 23:25:33 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <416F432D.4050706@pobox.com>
References: <qww8yaarph5.fsf@decibel.fi.muni.cz> <20041014205440.GY5414@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Petr Konecny <pekon@fi.muni.cz>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20041014205440.GY5414@waste.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Matt Mackall wrote:
> On Thu, Oct 14, 2004 at 04:41:10AM +0200, Petr Konecny wrote:
> 
>>Hi,
>>
>>I have a headless computer with xircom pcmcia card and needed netconsole
>>on it. After looking around in other drivers I concocted this patch.  It
>>survived light testing. I have no documentation for the hw, so it maybe
>>totally bogus. What do you think ?
> 
> 
> Looks good to me.
> 
> In general, this generic approach is fine. We can sometimes avoid the
> heavyweight IRQ manipulation by using internal driver locking, but
> this is generally not a performance-critical path. 
> 
> Jeff, did you take this one?


yes
