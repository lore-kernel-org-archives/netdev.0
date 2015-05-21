From: Hannes Reinecke <hare-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [RFC PATCH 0/4] Make iSCSI network namespace aware
Date: Thu, 21 May 2015 11:04:46 +0200
Message-ID: <555D9FAE.5060905@suse.de>
References: <1431555167-23995-1-git-send-email-cleech@redhat.com> <555CD657.6080004@redhat.com>
Reply-To: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
To: Andy Grover <agrover-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
 linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <open-iscsi+bncBCHZVHVFVMARBMF762VAKGQERH5LZZA-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <555CD657.6080004-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Post: <http://groups.google.com/group/open-iscsi/post>, <mailto:open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:open-iscsi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/open-iscsi
Sender: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/open-iscsi/subscribe>, <mailto:open-iscsi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+856124926423+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <http://groups.google.com/group/open-iscsi/subscribe>
List-Id: netdev.vger.kernel.org

On 05/20/2015 08:45 PM, Andy Grover wrote:
> On 05/13/2015 03:12 PM, Chris Leech wrote:
>> This is only about the structures and functionality involved in
>> maintaining the
>> iSCSI session, the SCSI host along with it's discovered targets
>> and devices has
>> no association with network namespaces.
>>
>> These patches are functional, but not complete.  There's no
>> isolation enforced
>> in the kernel just yet, so it relies on well behaved userspace.  I
>> plan on
>> fixing that, but wanted some feedback on the idea and approach so
>> far.
>=20
> Seems like a good direction, to me.
>=20
> What would be the extent of the userspace (open-iscsi) changes
> needed to go along with this?
>=20
What I would like to see is to split off iscsid to have one
instance/process per session.
With that we could trivially run open-iscsi in containers and
stufflike; currently it'll be hard as there really is only one
iscsid expected to be running in a system.

Cheers,

Hannes
--=20
Dr. Hannes Reinecke		               zSeries & Storage
hare-l3A5Bk7waGM@public.gmane.org			               +49 911 74053 688
SUSE LINUX GmbH, Maxfeldstr. 5, 90409 N=C3=BCrnberg
GF: F. Imend=C3=B6rffer, J. Smithard, J. Guild, D. Upmanyu, G. Norton
HRB 21284 (AG N=C3=BCrnberg)

--=20
You received this message because you are subscribed to the Google Groups "=
open-iscsi" group.
To unsubscribe from this group and stop receiving emails from it, send an e=
mail to open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
To post to this group, send email to open-iscsi-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
Visit this group at http://groups.google.com/group/open-iscsi.
For more options, visit https://groups.google.com/d/optout.
