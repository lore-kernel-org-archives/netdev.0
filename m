From: Michal Marek <mmarek@suse.cz>
Subject: Re: linux-next: net/kbuild trees build failure
Date: Mon, 07 Dec 2009 13:22:50 +0100
Message-ID: <4B1CF39A.5050806@suse.cz>
References: <20091207200317.57820f0a.sfr@canb.auug.org.au> <20091207114158.GA2428@merkur.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Reinette Chatre <reinette.chatre@intel.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: Sam Ravnborg <sam@ravnborg.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20091207114158.GA2428@merkur.ravnborg.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7.12.2009 12:41, Sam Ravnborg wrote:
> On Mon, Dec 07, 2009 at 08:03:17PM +1100, Stephen Rothwell wrote:
>> Hi Dave,
>>
>> Today's linux-next build (powerpc allyesconfig) failed like this:
>>
>> In file included from drivers/net/wireless/iwlwifi/iwl3945-base.c:57:
>> drivers/net/wireless/iwlwifi/iwl-core.h:66:30: error: linux/utsrelease.h: No such file or directory
>>
>> Caused by commit 250cce26d5d03337aec4ff8405121f026adb4a89 ("iwlwifi:
>> driver version track kernel version") from the net tree interacting with
>> commit 8e5c76aace9705b6983cfbf5eb2f2e869dab6738 ("kbuild: move
>> utsrelease.h to include/generated") from the kbuild tree.
>>
>> I applied this patch for today (and will carry it as necessary):
> 
> The right fix would be to use 'utsname()->sysname' (I think sysname
> is the right member).

->release would be the right one. One could also question why iwlwifi
needs to repeat the kernel version it was built / is running against,
but I that's not the point here :). Dave, John, can we agree that
whichever tree gets merged first, the other tree applies the one-liner?

Thanks!
Michal
