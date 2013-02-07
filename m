From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH, resubmit] ax88179_178a: ASIX AX88179_178A USB 3.0/2.0
 to gigabit ethernet adapter driver
Date: Wed, 6 Feb 2013 21:45:25 -0800
Message-ID: <20130206214525.5c5775fe@nehalam.linuxnetplumber.net>
References: <1360211794-4737-1-git-send-email-freddy@asix.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
To: Freddy Xin <freddy@asix.com.tw>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1360211794-4737-1-git-send-email-freddy@asix.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu,  7 Feb 2013 12:36:34 +0800
Freddy Xin <freddy@asix.com.tw> wrote:

> +struct {unsigned char ctrl, timer_l, timer_h, size, ifg; }
> +AX88179_BULKIN_SIZE[] =	{
> +	{7, 0x4f, 0,	0x12, 0xff},
> +	{7, 0xf0, 1,	0x15, 0xff},
> +	{7, 0xae, 7,	0x18, 0xff},
> +	{7, 0xcc, 0x4c, 0x18, 8},
> +};

Better to make it static, const, and add a couple
of line breaks.

static const struct {
      unsigned char ctrl, timer_l, timer_h, size, ifg;
} AX88179_BULKIN_SIZE[] =	{
	{7, 0x4f, 0,	0x12, 0xff},
	{7, 0xf0, 1,	0x15, 0xff},
	{7, 0xae, 7,	0x18, 0xff},
	{7, 0xcc, 0x4c, 0x18, 8},
};
