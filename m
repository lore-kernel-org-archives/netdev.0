From: Grant Grundler <grundler@chromium.org>
Subject: Re: [PATCH 5/5] net-next:asix: v2 update VERSION only
Date: Tue, 15 Nov 2011 17:37:47 -0800
Message-ID: <CANEJEGtnUS5B1ggdoPn8gcCbFm==dfgHCgXVgcgpuooFUAowJA@mail.gmail.com>
References: <1321318357-17723-1-git-send-email-grundler@chromium.org>
	<21257.1321403368@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Allan Chou <allan@asix.com.tw>,
	Freddy Xin <freddy@asix.com.tw>
To: Valdis.Kletnieks@vt.edu
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <21257.1321403368@turing-police.cc.vt.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 15, 2011 at 4:29 PM,  <Valdis.Kletnieks@vt.edu> wrote:
> On Mon, 14 Nov 2011 16:52:37 PST, Grant Grundler said:
>
>> -#define DRIVER_VERSION "26-Sep-2011"
>> +#define DRIVER_VERSION "08-Nov-2011"
>
> Aren't these sort of things more than a tad silly for an in-kernel driver?

Definitely not. Supporting linux device drivers essentially requires
some mechanism like this. We could use anything (SHA1, Mayan Calendar,
etc). This driver happens to use a ISO-like date code.

Upstream drivers are routinely back ported to distro releases. Version
is the primary means for a vendor (like ASIX) to determine what was
back ported. Distro maintainers and 1st tier support organizations
also need to track versions and "ethtool -i" is the canonical way to
look this up on a running system.

grant
