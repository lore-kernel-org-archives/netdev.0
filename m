From: "Vladimir B. Savkin" <master@sectorb.msk.ru>
Subject: Re: 2.6.8-rc4-bk1 problem: unregister_netdevice: waiting for ppp0 to become free. Usage count = 1
Date: Fri, 13 Aug 2004 12:03:34 +0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040813080334.GA13337@tentacle.sectorb.msk.ru>
References: <411BC284.6080807@vgertech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Nuno Silva <nuno.silva@vgertech.com>
Content-Disposition: inline
In-Reply-To: <411BC284.6080807@vgertech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Aug 12, 2004 at 08:18:28PM +0100, Nuno Silva wrote:
> Hi!
> 
> With 2.6.8-rc4-bk1 I get "Aug 12 17:33:10 puma kernel:
> unregister_netdevice: waiting for ppp0 to become free. Usage count = 1"
> in the logs after pppd exit.
> 
> Also, the box won't reboot and print that message forever in the
> console. sysrq-U && sysrq-R did it :-)
> 
> The last version I tried was 2.6.8-rc2-bk11 and, wrt this prob, is
> running fine. So, the problem is in that window and the changelog for
> rc4 mentions something about ppp:
> http://kernel.org/pub/linux/kernel/v2.6/testing/ChangeLog-2.6.8-rc4
> 
> If someone requires more information or tests feel free to ask!

I saw this too, with 2.6.7-rc3-mm1.
I have discovered that it happens because of idle TCP socket
holds a reference to a network device.
After killing associated process, device was freed immediately.

~
:wq
                                        With best regards, 
                                           Vladimir Savkin. 
