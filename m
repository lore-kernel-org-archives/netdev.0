From: "Alejandro Bonilla" <abonilla@linuxwireless.org>
Subject: RE: IPW2100 Kconfig
Date: Thu, 8 Sep 2005 15:17:38 -0600
Message-ID: <008501c5b4ba$be1a7990$a20cc60a@amer.sykes.com>
References: <c775eb9b05090814114f258dc9@mail.gmail.com>
Reply-To: <abonilla@linuxwireless.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751410AbVIHVRu@vger.kernel.org>
To: "'Bharath Ramesh'" <krosswindz@gmail.com>,
	"'Pavel Machek'" <pavel@ucw.cz>
In-Reply-To: <c775eb9b05090814114f258dc9@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> AFAIK hotplug looks for firmware in /lib/firmware and not
> /etc/firmware.
>
> On 9/8/05, Pavel Machek <pavel@ucw.cz> wrote:
> > Hi!
> >
> > >       I checked the IPW2100 in the current git from
> linux-2.6 and the menuconfig
> > > help (Kconfig) says you need to put the firmware in
> /etc/firmware, it should
> > > be /lib/firmware.
> > >
> > > Who should I send the "patch" to? Or can someone simply
> change that?
> >
> > Are you sure it is not distro-dependend?
> > --

Right, IPW2100 came with Legacy fw load first. Maybe that was dragged from
long time ago and used incorrectly.

I'm 100% sure that new versions of hotplug try to look at /lib/firmware and
was /usr/lib/hotplug/firmware before, but there was some discussion that
/lib would make more sense cause /usr could be dependant on other stuff.

Jesper already signed the patch.

.Alejandro
