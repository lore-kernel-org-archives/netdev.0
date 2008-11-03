From: "Alexander Beregalov" <a.beregalov@gmail.com>
Subject: Re: e100/netconsole: Failed to load firmware (Re: linux-next: Tree for November 3)
Date: Mon, 3 Nov 2008 19:42:02 +0300
Message-ID: <a4423d670811030842v814c7f9x84de7803e8a96883@mail.gmail.com>
References: <a4423d670811030425y1bdf93fcn829b7311e38731b9@mail.gmail.com>
	 <a4423d670811030749l53098b34i21af579c13ba112e@mail.gmail.com>
	 <1225727806.745.7.camel@macbook.infradead.org>
	 <20081103160057.GA12456@orion>
	 <1225728567.745.13.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, jaswinder@infradead.org,
	linux-next@vger.kernel.org, Netdev <netdev@vger.kernel.org>
To: "David Woodhouse" <dwmw2@infradead.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1225728567.745.13.camel@macbook.infradead.org>
Content-Disposition: inline
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2008/11/3 David Woodhouse <dwmw2@infradead.org>:
> On Mon, 2008-11-03 at 19:00 +0300, Alexander Beregalov wrote:
>> # CONFIG_FIRMWARE_IN_KERNEL is not set
>> CONFIG_EXTRA_FIRMWARE=""
>
> OK, so you didn't include the E100 firmware in the kernel, so it only
> actually manages to bring up the E100 after it's mounted the root file
> system, not in time for the console?
>
> If you set CONFIG_FIRMWARE_IN_KERNEL, does it work?
Oh, I forget this option, sorry.

Yes, it works, thanks.
>
> I think that's fairly much expected behaviour. I wonder if there's a way
> we could make it slightly more intuitive though.
