From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for vbus_driver
 objects
Date: Wed, 19 Aug 2009 00:27:03 -0400
Message-ID: <4A8B7F17.6050100@gmail.com>
References: <20090814154125.26116.70709.stgit@dev.haskins.net> <20090814154308.26116.46980.stgit@dev.haskins.net> <20090815103243.GA26749@elte.hu> <4A870964.9090408@codemonkey.ws> <4A8965E0.8050608@gmail.com> <4A89FF08.30509@codemonkey.ws> <4A8AA9BD.2070909@gmail.com> <4A8AB076.6080906@redhat.com> <4A8ACE1F.6020402@gmail.com> <20090818161434.GA15884@elte.hu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig071D05B157386F91C53B8664"
Cc: Avi Kivity <avi@redhat.com>,
	Anthony Liguori <anthony@codemonkey.ws>,
	Gregory Haskins <ghaskins@novell.com>, kvm@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20090818161434.GA15884@elte.hu>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig071D05B157386F91C53B8664
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Ingo Molnar wrote:
> * Gregory Haskins <gregory.haskins@gmail.com> wrote:
>=20
>>> You haven't convinced me that your ideas are worth the effort=20
>>> of abandoning virtio/pci or maintaining both venet/vbus and=20
>>> virtio/pci.
>> With all due respect, I didnt ask you do to anything, especially=20
>> not abandon something you are happy with.
>>
>> All I did was push guest drivers to LKML.  The code in question=20
>> is independent of KVM, and its proven to improve the experience=20
>> of using Linux as a platform.  There are people interested in=20
>> using them (by virtue of the number of people that have signed up=20
>> for the AlacrityVM list, and have mailed me privately about this=20
>> work).
>=20
> This thread started because i asked you about your technical=20
> arguments why we'd want vbus instead of virtio.

(You mean vbus vs pci, right?  virtio works fine, is untouched, and is
out-of-scope here)

Right, and I do believe I answered your questions.  Do you feel as
though this was not a satisfactory response?


> Your answer above=20
> now basically boils down to: "because I want it so, why dont you=20
> leave me alone".

Well, with all due respect, please do not put words in my mouth.  This
is not what I am saying at all.

What I *am* saying is:

fact: this thread is about linux guest drivers to support vbus

fact: these drivers do not touch kvm code.

fact: these drivers to not force kvm to alter its operation in any way.

fact: these drivers do not alter ABIs that KVM currently supports.

Therefore, all this talk about "abandoning", "supporting", and
"changing" things in KVM is, premature, irrelevant, and/or, FUD.  No one
proposed such changes, so I am highlighting this fact to bring the
thread back on topic.  That KVM talk is merely a distraction at this
point in time.

>=20
> What you are doing here is to in essence to fork KVM,

No, that is incorrect.  What I am doing here is a downstream development
point for the integration of KVM and vbus.  Its akin to kvm.git or
tip.git to develop a subsystem intended for eventual inclusion upstream.
 If and when the code goes upstream in a manner acceptable to all
parties involved, and AlacrityVM exceeds its utility as a separate
project, I will _gladly_ dissolve it and migrate to use upstream KVM
instead.

As stated on the project wiki: "It is a goal of AlacrityVM to work
towards upstream acceptance of the project on a timeline that suits the
community. In the meantime, this wiki will serve as the central
coordination point for development and discussion of the technology"

(citation: http://developer.novell.com/wiki/index.php/AlacrityVM)

And I meant it when I said it.

Until then, the project is a much more efficient way for us (the vbus
developers) to work together than pointing people at my patch series
posted to kvm@vger.  I tried that way first.  It sucked, and didn't
work.  Users were having trouble patching the various pieces, building,
etc.  Now I can offer a complete solution from a central point, with all
the proper pieces in place to play around with it.

Ultimately, it is up to upstream to decide if this is to become merged
or remain out of tree forever as a "fork".  Not me.  I will continue to
make every effort to find common ground with my goals coincident with
the blessing of upstream, as I have been from the beginning.  Now I have
a more official forum to do it in.

> regardless of=20
> the technical counter arguments given against such a fork and=20
> regardless of the ample opportunity given to you to demostrate the=20
> technical advantages of your code. (in which case KVM would happily=20
> migrate to your code)

In an ideal world, perhaps.  Avi and I currently have a fundamental
disagreement about the best way to do PV.  He sees the world through PCI
glasses, and I don't.  Despite attempts on both sides to rectify this
disagreement, we currently do not see eye to eye on every front.

This doesn't mean he is right, and I am wrong per se.  It just means we
disagree.  Period.  Avi is a sharp guy, and I respect him.  But upstream
KVM doesn't have a corner on "correct" ;)  The community as a whole will
ultimately decide if my ideas live or die, wouldn't you agree?

Avi can correct me if I am wrong, but what we _do_ agree on is that core
KVM doesn't need to be directly involved in this vbus (or vhost)
discussion, per se.  It just wants to have the hooks to support various
PV solutions (such as irqfd/ioeventfd), and vbus is one such solution.

>=20
> We all love faster code and better management interfaces and tons=20
> of your prior patches got accepted by Avi. This time you didnt even=20
> _try_ to improve virtio.

Im sorry, but you are mistaken:

http://lkml.indiana.edu/hypermail/linux/kernel/0904.2/02443.html

> It's not like you posted a lot of virtio=20
> patches which were not applied. You didnt even try and you need to=20
> try _much_ harder than that before forking a project.

I really do not think you are in a position to say when someone can or
cannot fork a project, so please do not try to lecture on that.  Perhaps
you could offer advice on when someone, in your opinion, *should* or
*should not* fork, because that would be interesting to hear.

You are also wrong to say that I didn't try to avoid creating a
downstream effort first.   I believe the public record of the mailing
lists will back me up that I tried politely pushing this directly though
kvm first.  It was only after Avi recently informed me that they would
be building their own version of an in-kernel backend in lieu of working
with me to adapt vbus to their needs that I decided to put my own
project together.

What should I have done otherwise, in your opinion?

>=20
> And fragmentation matters quite a bit. To Linux users, developers,=20
> administrators, packagers it's a big deal whether two overlapping=20
> pieces of functionality for the same thing exist within the same=20
> kernel.

So the only thing that could be construed as overlapping here is venet
vs virtio-net. If I dropped the contentious venet and focused on making
a virtio-net backend that we can all re-use, do you see that as a path
of compromise here?

> The kernel is not an anarchy where everyone can have their=20
> own sys_fork() version or their own sys_write() version. Would you=20
> want to have two dozen read() variants, sys_read_oracle() and a=20
> sys_read_db2()?

No, and I am not advocating that either.

>=20
> I certainly dont want that. Instead we (at great expense and work)=20
> try to reach the best technical solution.

This is all I want, as well.

> That means we throw away=20
> inferior code and adopt the better one. (with a reasonable=20
> migration period)
>=20
> You are ignoring that principle with hand-waving about 'the=20
> community wants this'.

I call it like I see it.  I get private emails all the time encouraging
my efforts and asking about the project.  I'm sorry if you see this as
hand-waving.  Perhaps the people involved will become more vocal in the
community to back me up, perhaps not.  Time will tell.


> I can assure you, users _DONT WANT_ split=20
> interfaces and incompatible drivers for the same thing. They want=20
> stuff that works well.

And I can respect that, and am trying to provide that.

>=20
> If the community wants this then why cannot you convince one of the=20
> most prominent representatives of that community, the KVM=20
> developers?

Its a chicken and egg at times.  Perhaps the KVM developers do not have
the motivation or time to properly consider such a proposal _until_ the
community presents its demand.  And sometimes you cannot build demand
unless you have an easy way to use the idea, such as a project to back
it.  Since vbus+kvm has many moving parts (guest side, host-side,
userspace-side, etc), its difficult to use as a patch series pulled in
from a mailing list.

This is the role of the AlacrityVM project.  Make it easy to use and
develop.  If it draws a community, perhaps KVM will reconsider its
stance.  If it does not draw a community, it will naturally die.  End of
story.

But please do not confuse one particular groups opinion as the sole
validation of an idea, no matter how "prominent".  There are numerous
reasons why one group may hold an opinion that have nothing to do with
the actual technical merits of the idea, or the community demand for it.

>=20
> Furthermore, 99% of your work is KVM

Actually, no.  Almost none of it is.  I think there are about 2-3
patches in the series that touch KVM, the rest are all original (and
primarily stand-alone code).  AlacrityVM is the application of kvm and
vbus (and, of course, Linux) together as a complete unit, but I do not
try to hide this relationship.

By your argument, KVM is 99% QEMU+Linux. ;)

> why dont you respect that work by not forking it?

Lighten up on the fork FUD, please.  It's counter productive.

Kind Regards,
-Greg


--------------enig071D05B157386F91C53B8664
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkqLfxcACgkQP5K2CMvXmqE5pQCfSWpDDv87OIG7Azs4Z94WVaYt
GmcAn2/rV+n3RTdPb6LWmkdSwBRYhdAg
=3EFB
-----END PGP SIGNATURE-----

--------------enig071D05B157386F91C53B8664--
