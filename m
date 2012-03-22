From: Knut Petersen <Knut_Petersen@t-online.de>
Subject: Re: [PATCH] sky2: override for PCI legacy power management
Date: Thu, 22 Mar 2012 23:36:16 +0100
Message-ID: <4F6BA960.6020003@t-online.de>
References: <4F69BE2E.7070903@t-online.de> <20120321083205.360a7a3b@nehalam.linuxnetplumber.net> <CAErSpo67PEaZ6JuMUntWLfR8SUpQgZERD_cKV6rWd=FF0tZ6DQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>, arekm@maven.pl,
	Jared <nitro@legroom.net>, dilieto@lineone.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Bjorn Helgaas <bhelgaas@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAErSpo67PEaZ6JuMUntWLfR8SUpQgZERD_cKV6rWd=FF0tZ6DQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 21.03.2012 21:22, schrieb Bjorn Helgaas:
> It looks like this requires a user to figure out that he might be suf=
fering from this problem, then use this module parameter to work around=
 it. How would a user figure that out? Can we do it automatically to sa=
ve him the trouble?

It=B4s easy to dmi_match() known broken systems - I have dmidecode outp=
uts of four systems that definitely need the patch.
Two ASUSTek P5* mainboards with AMI BIOSes, two AOpen i915G* mainboards=
 with Award/Phoenix BIOSes.

cu,
  Knut
