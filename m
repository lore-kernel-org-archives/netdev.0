From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for vbus_driver
 objects
Date: Wed, 19 Aug 2009 09:27:51 -0400
Message-ID: <4A8BFDD7.4040900@gmail.com>
References: <20090814154125.26116.70709.stgit@dev.haskins.net> <20090814154308.26116.46980.stgit@dev.haskins.net> <20090815103243.GA26749@elte.hu> <4A870964.9090408@codemonkey.ws> <4A8965E0.8050608@gmail.com> <4A89FF08.30509@codemonkey.ws> <4A8AA9BD.2070909@gmail.com> <4A8AB076.6080906@redhat.com> <4A8ACE1F.6020402@gmail.com> <20090818161434.GA15884@elte.hu> <4A8B7F17.6050100@gmail.com> <4A8B8C11.9030800@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigAAEA98446DAF6C5A8992A5C1"
Cc: Ingo Molnar <mingo@elte.hu>,
	Anthony Liguori <anthony@codemonkey.ws>, kvm@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>,
	"Ira W. Snyder" <iws@ovro.caltech.edu>
To: Avi Kivity <avi@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752419AbZHSN15@vger.kernel.org>
In-Reply-To: <4A8B8C11.9030800@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigAAEA98446DAF6C5A8992A5C1
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Avi Kivity wrote:
> On 08/19/2009 07:27 AM, Gregory Haskins wrote:
>>
>>> This thread started because i asked you about your technical
>>> arguments why we'd want vbus instead of virtio.
>>>     =20
>> (You mean vbus vs pci, right?  virtio works fine, is untouched, and is=

>> out-of-scope here)
>>   =20
>=20
> I guess he meant venet vs virtio-net.  Without venet vbus is currently
> userless.
>=20
>> Right, and I do believe I answered your questions.  Do you feel as
>> though this was not a satisfactory response?
>>   =20
>=20
> Others and I have shown you its wrong.

No, you have shown me that you disagree.  I'm sorry, but do not assume
they are the same.

Case in point: You also said that threading the ethernet model was wrong
when I proposed it, and later conceded when I showed you the numbers
that you were wrong.  I don't say this to be a jerk.  I am wrong myself
all the time too.

I only say it to highlight that perhaps we just don't (yet) see each
others POV.  Therefore, do not be so quick to put a "wrong" label on
something, especially when the line of questioning/debate indicates to
me that there are still fundamental issues in understanding exactly how
things work.

>  There's no inherent performance
> problem in pci.  The vbus approach has inherent problems (the biggest o=
f
> which is compatibility

Trying to be backwards compatible in all dimensions is not a design
goal, as already stated.


, the second managability).
>=20

Where are the management problems?


>>> Your answer above
>>> now basically boils down to: "because I want it so, why dont you
>>> leave me alone".
>>>     =20
>> Well, with all due respect, please do not put words in my mouth.  This=

>> is not what I am saying at all.
>>
>> What I *am* saying is:
>>
>> fact: this thread is about linux guest drivers to support vbus
>>
>> fact: these drivers do not touch kvm code.
>>
>> fact: these drivers to not force kvm to alter its operation in any way=
=2E
>>
>> fact: these drivers do not alter ABIs that KVM currently supports.
>>
>> Therefore, all this talk about "abandoning", "supporting", and
>> "changing" things in KVM is, premature, irrelevant, and/or, FUD.  No o=
ne
>> proposed such changes, so I am highlighting this fact to bring the
>> thread back on topic.  That KVM talk is merely a distraction at this
>> point in time.
>>   =20
>=20
> s/kvm/kvm stack/.  virtio/pci is part of the kvm stack, even if it is
> not part of kvm itself.  If vbus/venet were to be merged, users and
> developers would have to choose one or the other.  That's the
> fragmentation I'm worried about.  And you can prefix that with "fact:"
> as well.

Noted

>=20
>>> We all love faster code and better management interfaces and tons
>>> of your prior patches got accepted by Avi. This time you didnt even
>>> _try_ to improve virtio.
>>>     =20
>> Im sorry, but you are mistaken:
>>
>> http://lkml.indiana.edu/hypermail/linux/kernel/0904.2/02443.html
>>   =20
>=20
> That does nothing to improve virtio.

I'm sorry, but thats just plain false.

> Existing guests (Linux and
> Windows) which support virtio will cease to work if the host moves to
> vbus-virtio.

Sigh...please re-read "fact" section.  And even if this work is accepted
upstream as it is, how you configure the host and guest is just that: a
configuration.  If your guest and host both speak vbus, use it.  If they
don't, don't use it.  Simple as that.  Saying anything else is just more
FUD, and I can say the same thing about a variety of other configuration
options currently available.


> Existing hosts (running virtio-pci) won't be able to talk
> to newer guests running virtio-vbus.  The patch doesn't improve
> performance without the entire vbus stack in the host kernel and a
> vbus-virtio-net-host host kernel driver.

<rewind years=3D2>Existing hosts (running realtek emulation) won't be abl=
e
to talk to newer guests running virtio-net.  Virtio-net doesn't do
anything to improve realtek emulation without the entire virtio stack in
the host.</rewind>

You gotta start somewhere.   You're argument buys you nothing other than
backwards compat, which I've already stated is not a specific goal here.
 I am not against "modprobe vbus-pcibridge", and I am sure there are
users out that that do not object to this either.

>=20
> Perhaps if you posted everything needed to make vbus-virtio work and
> perform we could compare that to vhost-net and you'll see another reaso=
n
> why vhost-net is the better approach.

Yet, you must recognize that an alternative outcome is that we can look
at issues outside of virtio-net on KVM and perhaps you will see vbus is
a better approach.

>=20
>> You are also wrong to say that I didn't try to avoid creating a
>> downstream effort first.   I believe the public record of the mailing
>> lists will back me up that I tried politely pushing this directly thou=
gh
>> kvm first.  It was only after Avi recently informed me that they would=

>> be building their own version of an in-kernel backend in lieu of worki=
ng
>> with me to adapt vbus to their needs that I decided to put my own
>> project together.
>>   =20
>=20
> There's no way we can adapt vbus to our needs.

Really?  Did you ever bother to ask how?  I'm pretty sure you can.  And
if you couldn't, I would have considered changes to make it work.


> Don't you think we'd preferred it rather than writing our own?

Honestly, I am not so sure based on your responses.

>  the current virtio-net issues
> are hurting us.

Indeed.

>=20
> Our needs are compatibility, performance, and managability.  vbus fails=

> all three, your impressive venet numbers notwithstanding.
>=20
>> What should I have done otherwise, in your opinion?
>>   =20
>=20
> You could come up with uses where vbus truly is superior to
> virtio/pci/whatever

I've already listed numerous examples on why I advocate vbus over PCI,
and have already stated I am not competing against virtio.

> (not words about etch constraints).

I was asked about the design, and that was background on some of my
motivations.   Don't try to spin that into something its not.

> Showing some of those non-virt uses, for example.

Actually, Ira's chassis discussed earlier is a classic example.  Vbus
actually fits neatly into his model, I believe (and much better than the
vhost proposals, IMO).

Basically, IMO we want to invert Ira's bus (so that the PPC boards see
host-based devices, instead of the other way around).  You write a
connector that transports the vbus verbs over the PCI link.  You write a
udev rule that responds to the PPC board "arrival" event to create a new
vbus container, and assign the board to that context.

Then, whatever devices you instantiate in the vbus container will
surface on the PPC board's "vbus-proxy" bus.  This can include "virtio"
type devices which are serviced by the virtio-vbus code to render these
devices to the virtio-bus.  Finally, drivers like virtio-net and
virtio-console load and run normally.

The host-side administers the available inventory on a per-board basis
and its configuration using sysfs operations.

> The fact that your only user duplicates existing functionality doesn't =
help.

Certainly at some level, that is true and is unfortunate, I agree.  In
retrospect, I wish I started with something non-overlapping with virtio
as the demo, just to avoid this aspect of controversy.

At another level, its the highest-performance 802.x interface for KVM at
the moment, since we still have not seen benchmarks for vhost.  Given
that I have spent a lot of time lately optimizing KVM, I can tell you
its not trivial to get it to work better than the userspace virtio.
Michael is clearly a smart guy, so the odds are in his favor.  But do
not count your chickens before they hatch, because its not guaranteed
success.

Long story short, my patches are not duplicative on all levels (i.e.
performance).  Its just another ethernet driver, of which there are
probably hundreds of alternatives in the kernel already.  You could also
argue that we already have multiple models in qemu (realtek, e1000,
virtio-net, etc) so this is not without precedent.  So really all this
"fragmentation" talk is FUD.  Lets stay on-point, please.

>=20
>=20
>>> And fragmentation matters quite a bit. To Linux users, developers,
>>> administrators, packagers it's a big deal whether two overlapping
>>> pieces of functionality for the same thing exist within the same
>>> kernel.
>>>     =20
>> So the only thing that could be construed as overlapping here is venet=

>> vs virtio-net. If I dropped the contentious venet and focused on makin=
g
>> a virtio-net backend that we can all re-use, do you see that as a path=

>> of compromise here?
>>   =20
>=20
> That's a step in the right direction.

Ok.  I am concerned it would be a waste of my time given your current
statements regarding the backend aspects of my design.

Can we talk more about that at some point?  I think you will see its not
some "evil, heavy duty" infrastructure that some comments seem to be
trying to paint it as.  I think its similar in concept to what you need
to do for a vhost like design, but (with all due respect to Michael) a
little bit more thought into the necessary abstraction points to allow
broader application.

>=20
>>> I certainly dont want that. Instead we (at great expense and work)
>>> try to reach the best technical solution.
>>>     =20
>> This is all I want, as well.
>>   =20
>=20
> Note whenever I mention migration, large guests, or Windows you say
> these are not your design requirements.

Actually, I don't think I've ever said that, per se.  I said that those
things are not a priority for me, personally.  I never made a design
decision that I knew would preclude the support for such concepts.  In
fact, afaict, the design would support them just fine, given resources
the develop them.

For the record: I never once said "vbus is done".  There is plenty of
work left to do.  This is natural (kvm I'm sure wasn't 100% when it went
in either, nor is it today)


> The best technical solution will have to consider those.

We are on the same page here.

>=20
>>> If the community wants this then why cannot you convince one of the
>>> most prominent representatives of that community, the KVM
>>> developers?
>>>     =20
>> Its a chicken and egg at times.  Perhaps the KVM developers do not hav=
e
>> the motivation or time to properly consider such a proposal _until_ th=
e
>> community presents its demand.
>=20
> I've spent quite a lot of time arguing with you, no doubt influenced by=

> the fact that you can write a lot faster than I can read.

:)

>=20
>>> Furthermore, 99% of your work is KVM
>>>     =20
>> Actually, no.  Almost none of it is.  I think there are about 2-3
>> patches in the series that touch KVM, the rest are all original (and
>> primarily stand-alone code).  AlacrityVM is the application of kvm and=

>> vbus (and, of course, Linux) together as a complete unit, but I do not=

>> try to hide this relationship.
>>
>> By your argument, KVM is 99% QEMU+Linux. ;)
>>   =20
>=20
> That's one of the kvm strong points...

As AlacrityVMs, as well ;)

Kind Regards,
-Greg



--------------enigAAEA98446DAF6C5A8992A5C1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkqL/dgACgkQP5K2CMvXmqHXUQCfSLOvi5E98V14xnvGTHQd6MiJ
yu4Amwco1CK8T+YaQuMFW09NrEHn1Mfr
=wBQX
-----END PGP SIGNATURE-----

--------------enigAAEA98446DAF6C5A8992A5C1--
