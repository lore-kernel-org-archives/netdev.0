From: "=?ISO-8859-1?Q?T=F6r=F6k_Edvin?=" <edwintorok@gmail.com>
Subject: Re: [PATCH] b44: power down PHY when interface down
Date: Sun, 1 Jul 2007 16:02:56 +0300
Message-ID: <4354d3270707010602p542512aex678b27217c0b2cb2@mail.gmail.com>
References: <4354d3270706300447ladcda4by987b1f87963112f9@mail.gmail.com>
	 <20070630120541.GA21339@srcf.ucam.org>
	 <46866C6B.9010801@linux.intel.com>
	 <20070630151923.GA22983@srcf.ucam.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Arjan van de Ven" <arjan@linux.intel.com>, netdev@vger.kernel.org,
	power@bughost.org, zambrano@broadcom.com,
	linux-kernel@vger.kernel.org
To: "Matthew Garrett" <mjg59@srcf.ucam.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757875AbXGANDO@vger.kernel.org>
In-Reply-To: <20070630151923.GA22983@srcf.ucam.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/30/07, Matthew Garrett <mjg59@srcf.ucam.org> wrote:
> On Sat, Jun 30, 2007 at 07:44:59AM -0700, Arjan van de Ven wrote:
> > Matthew Garrett wrote:
> > >Do you still get link beat detection when the phy is powered down?

No.
As for link detection on the switch connected to this card:
If I have WoL turned off, then I don't get link beat detection.
If I have WoL turned on, then PHY won't be powered down, and I get
link detection on the switch.

> > >
> > does that matter?
> > If the interface is down, nic drivers aren't expected to detect
> > link... if userspace wants to find link status it should have the
> > interface up.

I don't get link beat detection with the original driver either, when
interface is down
(unless I pass it -a, but then it will bring the interface up).


--Edwin
