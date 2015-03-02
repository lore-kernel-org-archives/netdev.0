From: Nicholas Krause <xerofoify@gmail.com>
Subject: Re: randconfig build error with next-20150302,
	in drivers/net/ethernet/intel/i40e/i40e_configfs.c
Date: Mon, 02 Mar 2015 15:17:58 -0500
Message-ID: <6D2AF351-FC1E-45DB-AFC9-AFED3284DC7E@gmail.com>
References: <CA+r1ZhiO8i7b4XQatEX-9X12M9hYPo5F51wrOCYdA8JSMOHnpg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jim Davis <jim.epost@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next <linux-next@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	jeffrey.t.kirsher@intel.com, e1000-devel@lists.sourceforge.net,
	netdev <netdev@vger.kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <CA+r1ZhiO8i7b4XQatEX-9X12M9hYPo5F51wrOCYdA8JSMOHnpg@mail.gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org



On March 2, 2015 11:29:12 AM EST, Jim Davis <jim.epost@gmail.com> wrote:
>Building with the attached random configuration file,
>
>drivers/built-in.o: In function `i40e_cfgfs_group_make_item':
>i40e_configfs.c:(.text+0x3df4ce): undefined reference to
>`config_item_init_type_name'
>drivers/built-in.o: In function `i40e_configfs_init':
>(.text+0x3df4ee): undefined reference to `config_group_init'
>drivers/built-in.o: In function `i40e_configfs_init':
>(.text+0x3df50c): undefined reference to `configfs_register_subsystem'
>drivers/built-in.o: In function `i40e_configfs_exit':
>(.text+0x3df52e): undefined reference to
>`configfs_unregister_subsystem'
>Makefile:939: recipe for target 'vmlinux' failed
>
>
>------------------------------------------------------------------------
>
>------------------------------------------------------------------------------
>Dive into the World of Parallel Programming The Go Parallel Website,
>sponsored
>by Intel and developed in partnership with Slashdot Media, is your hub
>for all
>things parallel software development, from weekly thought leadership
>blogs to
>news, videos, case studies, tutorials and more. Take a look and join
>the 
>conversation now. http://goparallel.sourceforge.net/
>
>------------------------------------------------------------------------
>
>_______________________________________________
>E1000-devel mailing list
>E1000-devel@lists.sourceforge.net
>https://lists.sourceforge.net/lists/listinfo/e1000-devel
>To learn more about Intel&#174; Ethernet, visit
>http://communities.intel.com/community/wired
Jim, 
I am on my phone so unfortunately I can't help now however, I can send in a patch later fixing this on Linux next. All I need is for you to resend directly to my email your.conf file for this rand configuration that is build failing. 
Nick 




-- 
Sent from my Android device with K-9 Mail. Please excuse my brevity.

------------------------------------------------------------------------------
Dive into the World of Parallel Programming The Go Parallel Website, sponsored
by Intel and developed in partnership with Slashdot Media, is your hub for all
things parallel software development, from weekly thought leadership blogs to
news, videos, case studies, tutorials and more. Take a look and join the 
conversation now. http://goparallel.sourceforge.net/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
