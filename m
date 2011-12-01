From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/4] nfc: Use standard logging styles
Date: Thu, 01 Dec 2011 10:48:38 -0800
Message-ID: <1322765318.30801.9.camel@joe2Laptop>
References: <cover.1322595343.git.joe@perches.com>
	 <6c89a76ddb76926febe36fe5be514cb186e39a76.1322595343.git.joe@perches.com>
	 <20111201155951.GF22609@sortiz-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Samuel Ortiz <sameo@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111201155951.GF22609@sortiz-mobl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2011-12-01 at 16:59 +0100, Samuel Ortiz wrote:
> Hi Joe,

Hello Samuel.

> On Tue, Nov 29, 2011 at 11:37:32AM -0800, Joe Perches wrote:
> > Using the normal logging styles is preferred over
> > subsystem specific styles when the subsystem does
> > not take a specific struct.
> > Convert nfc_<level> specific messages to pr_<level>
> > Add newlines to uses.
> I would be fine with moving to pr_debug, but I'd like the pr_fmt() routine to
> include the function name as well.

If you really want it I can add it back but
if you are not aware, dynamic debug can add
this by using:

echo "module nfc +fp" > <debugfs>/dynamic_debug/control
echo "module nci +fp" > <debugfs>/dynamic_debug/control

If you're getting dmesg logs from customers
that's a bit harder to track though.
