From: Nuno Silva <nuno.silva@vgertech.com>
Subject: Re: 2.6.8-rc4-bk1 problem: unregister_netdevice: waiting for ppp0
 to become free. Usage count = 1
Date: Fri, 13 Aug 2004 21:35:49 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <411D2625.2070908@vgertech.com>
References: <411BC284.6080807@vgertech.com> <20040813080334.GA13337@tentacle.sectorb.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Vladimir B. Savkin" <master@sectorb.msk.ru>
In-Reply-To: <20040813080334.GA13337@tentacle.sectorb.msk.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Vladimir B. Savkin wrote:
| On Thu, Aug 12, 2004 at 08:18:28PM +0100, Nuno Silva wrote:
|
|>Hi!
|>
|>With 2.6.8-rc4-bk1 I get "Aug 12 17:33:10 puma kernel:
|>unregister_netdevice: waiting for ppp0 to become free. Usage count = 1"
|>in the logs after pppd exit.
|>
|>Also, the box won't reboot and print that message forever in the
|>console. sysrq-U && sysrq-R did it :-)
|>
|>The last version I tried was 2.6.8-rc2-bk11 and, wrt this prob, is
|>running fine. So, the problem is in that window and the changelog for
|>rc4 mentions something about ppp:
|>http://kernel.org/pub/linux/kernel/v2.6/testing/ChangeLog-2.6.8-rc4
|>
|>If someone requires more information or tests feel free to ask!
|
|
| I saw this too, with 2.6.7-rc3-mm1.
| I have discovered that it happens because of idle TCP socket
| holds a reference to a network device.
| After killing associated process, device was freed immediately.
|

I waited for 5 mins before sysrq-U && sysrq-R.
Anyway, if I 'killall pppd' and then issue 'ifconfig -a' the ifconfig
command will hang.

This didn't happen with 2.6.8-rc2-bk11 (the one I'm running now), so
something changed... I'm I the only one with ppp/pppd/pppoe who tried
2.6.8-rc4-bk1? :-) Any success reports?

Regards,
Nuno Silva

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://enigmail.mozdev.org

iD8DBQFBHSYlOPig54MP17wRAs1NAJ0dMRd7tqnpRk/tnxZj7xSeoUL3UgCgrk50
tnzeT6sy3CauOI5WK7HF16o=
=mkWf
-----END PGP SIGNATURE-----
