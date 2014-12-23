From: Jia-Ju Bai <baijiaju1990@163.com>
Subject: Re: [PATCH v3 1/3] igb: Add igb_disable_sriov in
	error handling
Date: Tue, 23 Dec 2014 21:22:51 +0800
Message-ID: <54996CAB.7080007@163.com>
References: <1419319024-30455-1-git-send-email-baijiaju1990@163.com>
	<54995097.8090105@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux.nics@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, bruce.w.allan@intel.com,
	jesse.brandeburg@intel.com, davem@davemloft.net
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <54995097.8090105@cogentembedded.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 12/23/2014 07:23 PM, Sergei Shtylyov wrote:
> Hello.
>
> On 12/23/2014 10:17 AM, Jia-Ju Bai wrote:
>
>> For linux-3.18.0
>
>    For the future: such words should be placed under --- tear line...
>
>> The driver lacks igb_disable_sriov in error handling,
>> which should match igb_enable_sriov in igb_probe.
>> This patch fixes this problem, and it has been tested in runtime.
>
>> Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
>> ---
>
>    .... here.
>
>>   drivers/net/ethernet/intel/igb/igb_main.c |    4 ++++
>>   1 file changed, 4 insertions(+)
>
> WBR, Sergei
>

Thanks. ^_^
I see that most patches in netdev mailing list do not mention the linux
kernel version, so is it necessary to write the version in the patch?


------------------------------------------------------------------------------
Dive into the World of Parallel Programming! The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
