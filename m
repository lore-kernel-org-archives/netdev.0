From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] realtek: Add switch variable to 'switch case not
 processed' messages
Date: Sat, 24 Sep 2016 11:35:00 -0500
Message-ID: <49094659-662d-a902-6740-ea3d1fea6660@lwfinger.net>
References: <1474654333.1849.5.camel@perches.com>
 <d091f73a6adf3bdaa09ab0399c22a9fdfe9b188c.1474654979.git.joe@perches.com>
 <f98d2cf1-802a-93c1-b219-ec45aa417940@lwfinger.net>
 <1474657363.1849.9.camel@perches.com> <20160924175555.01cae6dd@endymion>
 <1474733754.23838.3.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chaoming Li <chaoming_li@realsil.com.cn>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>, Jean Delvare <jdelvare@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474733754.23838.3.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/24/2016 11:15 AM, Joe Perches wrote:
> On Sat, 2016-09-24 at 17:55 +0200, Jean Delvare wrote:
>> Would it make sense to explicitly set the enum values, or add them as
>> comments, to make such look-ups easier?
>
> If you want to create enum->#ENUM structs and
> "const char *" lookup functions, please be my guest.
>
> otherwise, hex is at least a consistent way to display
> what should be infrequent output.

Displaying those values as hex is OK. As Joe says, they will not be shown very 
often.

I have patches that makes HAL_DEF_WOWLAN be a no-op for the rest of the drivers, 
and one that sets the enum values for that particular statement to hex values. I 
also looked at the other large enums and decided that they never need the human 
lookup.

Larry
