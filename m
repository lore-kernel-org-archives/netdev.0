From: Greg KH <gregkh@suse.de>
Subject: Re: Process for subsystem maintainers to get Hyper-V code out of
 staging.
Date: Mon, 14 Feb 2011 15:45:56 -0800
Message-ID: <20110214234556.GA9620@suse.de>
References: <8AFC7968D54FB448A30D8F38F259C56233F95737@TK5EX14MBXC114.redmond.corp.microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-ide@vger.kernel.org" <linux-ide@vger.kernel.org>,
	"Jame.Bottomley@HansenPartnership.com"
	<Jame.Bottomley@HansenPartnership.com>,
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	KY Srinivasan <kys@microsoft.com>,
	Hashir Abdi <habdi@microsoft.com>,
	Mike Sterling <Mike.Sterling@microsoft.com>,
	Haiyang Zhang <haiyangz@microsoft.com>
To: Hank Janssen <hjanssen@microsoft.com>
Return-path: <linux-ide-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <8AFC7968D54FB448A30D8F38F259C56233F95737@TK5EX14MBXC114.redmond.corp.microsoft.com>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 14, 2011 at 11:30:07PM +0000, Hank Janssen wrote:
>=20
> Stephen/James/David,
>=20
> Greetings to you all. As you might be aware, we submitted Hyper-V dri=
vers to the kernel 2009. =A0
> We have been extending these drivers with additional functionality an=
d our primary focus=20
> now is doing the work needed to exit the staging area.
>=20
> To give you some background, the following are Hyper-V specific Linux=
 drivers:
>=20
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 hv_vmbus=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0 The vmbus driver that is the bridge between guest and t=
he=20
> 			host
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 hv_storvsc=A0=A0=A0=A0=A0=
=A0=A0=A0=A0 The SCSI device driver
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 hv_blkvsc=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0 The IDE driver
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 hv_netvsc=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0 The network driver
>=20
> We think our drivers are pretty close to be reviewed by the subsystem=
 maintainers.
>=20
> We have been  working with Greg on  hv_vmbus, and several other drive=
r issues as it=20
> relates to exiting staging. And now we are looking for guidance for t=
he other drivers.
>=20
> 	1. Most important thing of course, did we contact the correct subsys=
tem=20
> 	    maintainers?
> 		i. IDE/Blkvsc		David Miller
> 		ii. SCSI/Storvsc		James Bottomley
> 		iii. Network/Netvsc	Stephen Hemminger

That's what the MAINTAINERS file says, right?

> 	2. What is the process to submit the code for review?

Like Documentation/SubmittingPatches shows, send patches.

> 	3. Which mailing list(s) do we need to use for the code reviews

Again, MAINTAINERS shows this.

> 	4. I assume normal patch format is required?

Yes.

> 	5. What additional information is needed

What's normally needed.

> 	6. Once they leave staging where do they need to go? Because they al=
l
> 	    pretty much come as a package we were thinking drivers/hyperv mi=
ght
> 	    be a good place.

That's up to the subsystem, if they want all network drivers in
drivers/net/ then they go there, same for scsi, it's up to the
maintainer.

> There are still a few outstanding items we are currently working on. =
But they should be=20
> wrapped up shortly. (There are a few remaining FIXME comments in the =
code we are
> cleaning up as I write this). But if possible we would like to get yo=
ur feedback even as
> we are addressing the issues we currently know about.

I would wait and only ask for review _after_ you fix the things you kno=
w
about first.  Otherwise it just wastes everyone's time.

thanks,

greg k-h
