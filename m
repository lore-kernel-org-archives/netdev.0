From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 3/8] brcm80211: Add and use brcmX_dbg_dump_hex
Date: Sun, 15 Jan 2012 01:21:50 -0800
Message-ID: <1326619310.6164.2.camel@joe2Laptop>
References: <cover.1326616556.git.joe@perches.com>
	 <289e8a2dcdbb03315ba41788a358f5afc4bacb1b.1326616556.git.joe@perches.com>
	 <4F1299C4.7020902@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Brett Rudley <brudley@broadcom.com>,
	Henry Ptasinski <henryp@broadcom.com>,
	Roland Vossen <rvossen@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Kan Yan <kanyan@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Arend van Spriel <arend@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F1299C4.7020902@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2012-01-15 at 10:17 +0100, Arend van Spriel wrote:
> On 01/15/2012 09:38 AM, Joe Perches wrote:
> 
> > +#ifdef DEBUG
> > +extern __printf(3, 4)
> 
> Just curious if I can learn something here. What does the __printf(3, 4) do?

It's a #define for gcc __attribute__((format (printf, ...)))
It makes gcc validate the printf format and arguments.

http://gcc.gnu.org/onlinedocs/gcc/Function-Attributes.html
