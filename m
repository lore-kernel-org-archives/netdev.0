From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] realtek: Add switch variable to 'switch case not
 processed' messages
Date: Mon, 26 Sep 2016 09:33:36 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB010988D@AcuExch.aculab.com>
References: <1474654333.1849.5.camel@perches.com>
         <d091f73a6adf3bdaa09ab0399c22a9fdfe9b188c.1474654979.git.joe@perches.com>
         <f98d2cf1-802a-93c1-b219-ec45aa417940@lwfinger.net>
         <1474657363.1849.9.camel@perches.com>
 <20160924175555.01cae6dd@endymion> <1474733754.23838.3.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
        Chaoming Li <chaoming_li@realsil.com.cn>,
        Kalle Valo <kvalo@codeaurora.org>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: 'Joe Perches' <joe@perches.com>, Jean Delvare <jdelvare@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474733754.23838.3.camel@perches.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> If you want to create enum->#ENUM structs and
> "const char *" lookup functions, please be my guest.
> 
> otherwise, hex is at least a consistent way to display
> what should be infrequent output.

If I've typed it right:

#define tags(x) x(A) x(B) x(C)
#define x(t) t,
enum {tags(x) tag_count};
#undef x
#define x(t) ##t,
static const char names[] = { tags(x) };
#undef x

	David
