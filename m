From: "Michael Chan" <mchan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH 1/3] bnx2: Add support for CNIC driver.
Date: Thu, 22 May 2008 21:52:48 -0700
Message-ID: <1551EAE59135BE47B544934E30FC4FC002AABD1C@nt-irva-0751.brcm.ad.broadcom.com>
References: <20080523034522.GA8612@linux.vnet.ibm.com>
Reply-To: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: "David Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, michaelc-hcNo3dDEHLuVc3sceRu5cw@public.gmane.org, "Anil Veerabhadrappa" <anilgv-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
To: paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Return-path: <grbounce-FC1hwAUAAAA0O9VQcsxVj1UPjHD9r3x_=glio-open-iscsi=m.gmane.org-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Content-class: urn:content-classes:message
In-Reply-To: <20080523034522.GA8612-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Sender: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Post: <mailto:open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <mailto:open-iscsi-help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://googlegroups.com/group/open-iscsi/subscribe>,
	<mailto:open-iscsi-unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org


Paul E. McKenney wrote:

> So if a second CNIC driver attempts to register, it gets -EBUSY or
> something, right?

There is only one CNIC driver and it will only register once per
BNX2 netdevice.

> > You are right.  We should just unconditionally set up the IRQ
> > information without checking for c_ops.  The data=20
> structures we set up
> > below are owned by us.
>=20
> OK.  Hmmm....  You cannot even get away with sarcasm these days!  ;-)

Hmm, not sure what's the sarcasm.  The code here is trying to set up
the IRQ information so that CNIC driver can see it.  Even if the CNIC
driver is deregistering or was never registered, it doesn't hurt to
set up that information.

Anyway, I'll add some comments to the code to explain this better when
I respin.

> Very good.  Could you please add a comment to that effect?  Otherwise
> people search for what data structure is being freed up.
>=20

Will do.  Thanks.
