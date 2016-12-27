From: Geoff Lansberry <geoff-R+k406RtEhcAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v3 3/3] nfc: trf7970a: Prevent repeated polling from
 crashing the kernel
Date: Tue, 27 Dec 2016 09:18:32 -0500
Message-ID: <CAO7Z3WJa0goJ-VXc7dvyz8imZtqby6QsC0QNH+uRAE8LhxqU2w@mail.gmail.com>
References: <1482380314-16440-1-git-send-email-geoff@kuvee.com>
 <1482380314-16440-3-git-send-email-geoff@kuvee.com> <20161224060141.GA9069@animalcreek.com>
 <CAO7Z3W+n85jbr8cmj3HJV1c+eL=oRh-XRy+O=iZ+mD=ov2WABA@mail.gmail.com> <20161224172439.GA15103@animalcreek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Lauro Ramos Venancio <lauro.venancio-430g2QfJUUCGglJvpFV4uA@public.gmane.org>,
        Aloisio Almeida Jr <aloisio.almeida-430g2QfJUUCGglJvpFV4uA@public.gmane.org>,
        Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
        mark.rutland-5wv7dgnIgG8@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Justin Bronder <justin-R+k406RtEhcAvxtiuMwx3w@public.gmane.org>,
        Jaret Cantu <jaret.cantu-jEh4hwF5bVhBDgjK7y7TUQ@public.gmane.org>
To: Mark Greer <mgreer-luAo+O/VEmrlveNOaEYElw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161224172439.GA15103-luAo+O/VEmrlveNOaEYElw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Mark - I will split this off soon.

In the meantime - here is some more info about how we use it.

We do use NFC structures.    I did find an interesting clue in that
there are certain bottles that cause neard to segfault,  I'm not sure
what is different about them.  We write a string, like
"coppola_chardonnay_2015" to the bottles.  Come to think of it, I
haven't done anything special to make that an ndef record, just
assumed that it would happen by default, I'll look into this further.
  Also, I've been running neard with --plugin nfctype2. Just in case
the problem was happening due to cycling through other tag types.   It
didn't seem to make any difference, but I have not gone back to
default.

Geoff
Geoff Lansberry


Engineering Guy
Kuv=C3=A9e, Inc
125 Kingston St., 3rd Floor
Boston, MA 02111
1-617-290-1118 (m)
geoff.lansberry (skype)
http://www.kuvee.com



On Sat, Dec 24, 2016 at 12:24 PM, Mark Greer <mgreer-luAo+O/VEmrlveNOaEYElw@public.gmane.org> wrote=
:
> On Sat, Dec 24, 2016 at 11:17:18AM -0500, Geoff Lansberry wrote:
>> Mark - I'm sorry, but I did not write this code, and therefore was not
>> able to accurately describe it.   It is fixing a different issue, not
>> the neard segfault that we are still chasing. Last week Jaret Cantu
>> sent a separate email explaining the purpose of the code, which had
>> you copied, did you see that?
>
> Hm, no, I didn't.  I received an email from Justin Bronder but not from
> Jaret Cantu.  Justin's email did help but is still pretty high-level.
> We need a clear understanding as to what is happening in the digital
> layer and the driver to know how execution is getting into a block of
> error handling code that should never be executed.  Once we understand
> that we can start thinking about what the best fix is.
>
>> Does it explain why it was done to
>> your satisfaction?   I've asked him to join in on the effort to push
>> the change upstream, however he will not be available until the new
>> year.
>
> I expect that it would help if he joins.  After the holidays is fine -
> I think many people are taking it easy for the next week or so, anyway.
>
>> I know you did suggest that we split off that change from the others,
>> and if now is the time to do that, let me know.   If you don't have
>> the email from Jaret, also please let me know and I will forward it to
>> you.
>
> I think it would help you if you split it off because the first two patch=
es
> have a good chance of being accepted but this one doesn't (yet).  If you
> separate the them, it will make it easier for Samuel to take the first tw=
o
> (or he may take the first two anyway but its always good to make it as
> easy maintainers as you can).
>
> Mark
> --
