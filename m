From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH] iwlwifi: out-of-bounds access in iwl_init_sband_channels
Date: Fri, 14 Aug 2015 10:14:23 +0300
Message-ID: <87h9o2l4ts.fsf@kamboji.qca.qualcomm.com>
References: <1439512532-7901-1-git-send-email-adrien+dev@schischi.me>
	<0BA3FCBA62E2DC44AF3030971E174FB32E7EA2CE@hasmsx107.ger.corp.intel.com>
	<20150814090408.1521e8fe.adrien+dev@schischi.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Grumbach\, Emmanuel" <emmanuel.grumbach@intel.com>,
	"Berg\, Johannes" <johannes.berg@intel.com>,
	"ilw\@linux.intel.com" <ilw@linux.intel.com>,
	"linux-wireless\@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Adrien Schildknecht <adrien+dev@schischi.me>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150814090408.1521e8fe.adrien+dev@schischi.me> (Adrien
	Schildknecht's message of "Fri, 14 Aug 2015 09:04:08 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrien Schildknecht <adrien+dev@schischi.me> writes:

> Hi,
>
>> On 08/14/2015 03:36 AM, Adrien Schildknecht wrote:
>> > Both loops of this function compare data from the 'chan' array and
>> > then check if the index is valid.
>> > 
>> > The 2 conditions should be inverted to avoid an out-of-bounds
>> > access.
>> > 
>> 
>> Was that found by a static analyzer or any other automated tool, or
>> was that the result of your very careful review?
>
> The error has been reported by KASan:
> ==================================================================
> BUG: KASan: out of bounds access in iwl_init_sband_channels+0x207/0x260 [iwlwifi] at addr ffff8800c2d0aac8
> Read of size 4 by task modprobe/329
> ==================================================================

Always try to add information like this to the commit log, it's very
useful.

-- 
Kalle Valo
