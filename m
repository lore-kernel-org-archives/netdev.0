From: Sujit K M <sjt.kar@gmail.com>
Subject: Re: [PATCH 1/1] UDEV - Add 'udevlom' command line param to start_udev
Date: Mon, 8 Nov 2010 14:12:56 +0530
Message-ID: <AANLkTin_rswTZn5RxH375u4xsoftQzMSPMRfUvy77fdX@mail.gmail.com>
References: <20101103165505.GA3281@fedora-14-r710.oslab.blr.amer.dell.com>
	<20101103180500.GA7441@kroah.com>
	<20101105025848.GA14021@pws490.domsch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg KH <greg@kroah.com>, "K, Narendra" <Narendra_K@dell.com>,
	"linux-hotplug@vger.kernel.org" <linux-hotplug@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Hargrave, Jordan" <Jordan_Hargrave@dell.com>,
	"Rose, Charles" <Charles_Rose@dell.com>
To: Matt Domsch <Matt_Domsch@dell.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <20101105025848.GA14021@pws490.domsch.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> At Linux Plumbers Conference today, this problem space was discussed
> once again, and I believe concensus on approach was reached. =A0Here
> goes:

Was the patch a starting point for the discussion.

> * If a 70-persistent-net.rules file sets a name, honor that. =A0This
> =A0preserves existing installs.
>
> * If BIOS provides indexes for onboard devices, honor that.
> ** Rename onboard NICs "lom[1-N]" as BIOS reports (# matches chassis =
labels)
> ** No rename for all others "ethX" (no change for NICs in PCI slots/U=
SB/others)
>
> * If neither are true, do not rename at all.

I would like to know what is the difference in the nomenclature for thi=
s.

>
> * Implementation will be:
> ** Udev rules to be included in upstream udev will read the index
> =A0 value from sysfs (provided by SMBIOS 2.6 info on kernels >=3D 2.6=
=2E36,
> =A0 PCI DSM info at some future point) if present, and rename LOMs
> =A0 based on that index value. =A0Distros will use these rules by def=
ault
> =A0 (Ubuntu and Fedora maintainers on board with the concept; I have
> =A0 not spoken with other distros yet.)
> ** Legacy distros with older udev rules will invoke biosdevname on
> =A0 kernels < 2.6.36 to get the same information, if present, and wil=
l
> =A0 rename LOMs based on index value.

How will you manage these scenarios.
--
To unsubscribe from this list: send the line "unsubscribe linux-hotplug=
" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
