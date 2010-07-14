From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: Re: e1000e: receives no packets after resume
 (2.6.35-rc3-00262-g984bc96)
Date: Wed, 14 Jul 2010 13:22:25 -0600
Message-ID: <EA929A9653AAE14F841771FB1DE5A1365FF4B057A0@rrsmsx501.amr.corp.intel.com>
References: <20100702072826.GB16856@schottelius.org>
	<AANLkTikO8yXXBC9Wt4LKZeu1JD5TKMOW5reB3jpk8Ahp@mail.gmail.com>
	<20100703081732.GA24281@schottelius.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	netdev <netdev@vger.kernel.org>, "Allan,
	Bruce W" <bruce.w.allan@intel.com>, LKML <linux-kernel@vger.kernel.org>
To: Nico Schottelius <nico-linux-20100702@schottelius.org>, "Kirsher, Jeffrey
	T" <jeffrey.t.kirsher@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20100703081732.GA24281@schottelius.org>
Content-Language: en-US
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Nico Schottelius wrote:
> Hey Jeff,
> 
> Jeff Kirsher [Fri, Jul 02, 2010 at 02:47:26PM -0700]:
>> On Fri, Jul 2, 2010 at 00:28, Nico Schottelius
>> <nico-linux-20100702@schottelius.org> wrote:
>> [...]
>> Adding the Networking Kernel mailing list (netdev) and Intel Linux
>> LAN Driver mailing list (e1000-patches)...
>> 
>> Would it be possible to get more information about the system/setup?
>> 
>> For example, can you provide the following information:
>>      - full lspci output (lspci -vvv)
>>      - ethtool -i ethX
>>      - dmesg  - after loading the driver and configuring the
>> interfaces 
>>      - kernel config
> 
> Attached!
> 
> Cheers,
> 
> Nico

<snip>

>[   12.228826] e1000e 0000:00:19.0: irq 44 for MSI/MSI-X
>[   12.279610] e1000e 0000:00:19.0: irq 44 for MSI/MSI-X
>[   12.280200] ADDRCONF(NETDEV_UP): eth0: link is not ready
>[   18.282340] e1000e 0000:00:19.0: eth0: Error reading PHY register

Note the error from your dmesg log. This is a known issue and we are working on it.
In meantime you should be able to w/a it by reloading the driver.

Thanks,
Emil

------------------------------------------------------------------------------
This SF.net email is sponsored by Sprint
What will you do first with EVO, the first 4G phone?
Visit sprint.com/first -- http://p.sf.net/sfu/sprint-com-first
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
