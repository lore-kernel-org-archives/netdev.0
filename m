From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [PATCH v10 net-next 0/6] net: low latency
	Ethernet device polling
Date: Tue, 11 Jun 2013 09:49:31 +0300
Message-ID: <51B6C87B.70101@linux.intel.com>
References: <20130610083929.6955.87206.stgit@ladj378.jer.intel.com>
	<20130610.134116.1913599114372510768.davem@davemloft.net>
	<51B68AA6.1050105@linux.intel.com>
	<20130610.212443.1096102996038709384.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: willemb@google.com, or.gerlitz@gmail.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, hpa@zytor.com, amirv@mellanox.com,
	linux-kernel@vger.kernel.org, eliezer@tamir.org.il,
	jesse.brandeburg@intel.com, andi@firstfloor.org,
	bhutchings@solarflare.com, erdnetdev@gmail.com, eilong@broadcom.com
To: David Miller <davem@davemloft.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20130610.212443.1096102996038709384.davem@davemloft.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 11/06/2013 07:24, David Miller wrote:
> From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
> Date: Tue, 11 Jun 2013 05:25:42 +0300
>
>> Here is the text from the RFC and v2 cover letters, updated and
>> merged.  If this is too long, please tell me what you think should
>> be removed.
>
> It's perfect, and since this went through so many iterations I
> included the changelog too.
>

Thank you.

I would like to hear opinions on what needs to be added to make this
feature complete.

The list I have so far is:
1. add a socket option
2. support for poll/select
3. support for epoll

Also, would you accept a trailing whitespace cleanup patch for
fs/select.c?

-Eliezer

------------------------------------------------------------------------------
This SF.net email is sponsored by Windows:

Build for Windows Store.

http://p.sf.net/sfu/windows-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
