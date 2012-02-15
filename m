From: Tim Gardner <rtg.canonical@gmail.com>
Subject: Re: [PATCH v3] rtlwifi: rtl8192se firmware load can overflow target
 buffer
Date: Wed, 15 Feb 2012 12:34:12 -0700
Message-ID: <4F3C08B4.8010103@canonical.com>
References: <1328833192-10681-1-git-send-email-Larry.Finger@lwfinger.net> <20120215185525.GE4379@tuxdriver.com> <4F3C0421.20506@lwfinger.net>
Reply-To: tim.gardner@canonical.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Tim Gardner <tim.gardner@canonical.com>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F3C0421.20506@lwfinger.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/15/2012 12:14 PM, Larry Finger wrote:
> On 02/15/2012 12:55 PM, John W. Linville wrote:
>> Is this a fix that should go to 3.3?
>
> That code has been in the driver since 3.0 and it should probably be
> packported. On the other hand, Tim's report is the first one. My
> suggestion is that it go into 3.4.
>
> In addition, I am working on a fix that will completely eliminate all
> this fixed storage.
>
> Larry
>
>

I'm fine with it being 3.4 material. The patch addresses an unlikely 
scenario.

rtg
-- 
Tim Gardner tim.gardner@canonical.com
