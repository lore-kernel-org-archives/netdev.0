From: "Dave Young" <hidave.darkstar@gmail.com>
Subject: Re: [PATCH RFC] [1/9] Core module symbol namespaces code and intro.
Date: Fri, 23 Nov 2007 10:06:58 +0800
Message-ID: <a8e1da0711221806r5bc80cfchfa65b96a37d6d20a@mail.gmail.com>
References: <20071122343.446909000@suse.de>
	 <200711221456.22297.rusty@rustcorp.com.au>
	 <a8e1da0711220041v3d3c27d2pf7f326185666420d@mail.gmail.com>
	 <200711221919.11071.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Rusty Russell" <rusty@rustcorp.com.au>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, sam@ravnborg.org
To: "Andi Kleen" <ak@suse.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755811AbXKWCHg@vger.kernel.org>
In-Reply-To: <200711221919.11071.ak@suse.de>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Nov 23, 2007 2:19 AM, Andi Kleen <ak@suse.de> wrote:
>
> > Andy, I like your idea.  IMHO, as Rusty said a simple EXPORT_SYMBOL_TO
> > is better.
>
> I don't think so. e.g. tcpcong would be very very messy this way.
>
> > And I wonder if it is possible to export to something like  the struct
> > device_driver? If it's possible then it will not limited to modules.
>
> Not sure I follow you. Can you expand?
>
I know little about module internal, so if I'm wrong please just don't
mind, please  point out or just ignore.

Kernel symbols could apply to kernel object model, doesn't it?
I just think that because the device_driver have a mod_name member
(for built-in module), so if something can be done as device driver is
registered.
